provider "google" {
#  credentials = file("/Users/akshaydipta/Downloads/finovo-466315-0e970e92573f.json")
  credentials = var.credentials_json
  project     = var.project
  region      = var.region
}

# Grant your deployer SA the "actAs" right on the Cloud Run runtime SA
data "google_project" "this" {}

resource "google_project_service" "run" {
  service = "run.googleapis.com"
  project = var.project
  disable_on_destroy = false
}

resource "google_project_service" "artifact_registry" {
  service = "artifactregistry.googleapis.com"
  project = var.project
  disable_on_destroy = false
}

# NEW: Enable Cloud SQL Admin API
resource "google_project_service" "sqladmin" {
  service = "sqladmin.googleapis.com"
  project = var.project
  disable_on_destroy = false
}

# NEW: Enable Secret Manager API
resource "google_project_service" "secretmanager" {
  service = "secretmanager.googleapis.com"
  project = var.project
  disable_on_destroy = false
}

locals {
  runtime_sa_email = "${data.google_project.this.number}-compute@developer.gserviceaccount.com"
  runtime_sa_id    = "projects/${data.google_project.this.project_id}/serviceAccounts/${local.runtime_sa_email}"
}

resource "google_service_account_iam_member" "run_sa_act_as" {
  service_account_id = local.runtime_sa_id     # full resource name!
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.deployer_sa_email}"
}

# NEW: Grant the Cloud Run runtime SA the Cloud SQL Client role
resource "google_project_iam_member" "cloud_run_cloudsql_client_role" {
  project = var.project
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${local.runtime_sa_email}"
  # Ensures the service account has permissions before Cloud Run attempts to connect
  depends_on = [google_project_service.sqladmin]
}

# NEW: Secret Manager secret for the database password
resource "google_secret_manager_secret" "db_password_secret" {
  project   = var.project
  secret_id = "${var.service_name}-db-password"

  replication {
    auto {}
  }

  labels = {
    "managed-by" = "terraform"
  }
  # Dependency to ensure Secret Manager API is enabled before creating secret
  depends_on = [google_project_service.secretmanager]
}

# NEW: Secret version for the database password
resource "google_secret_manager_secret_version" "db_password_secret_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = var.db_password
}

# NEW: Random UUID for the internal Kubernetes Secret name (required by Cloud Run annotation)
resource "random_uuid" "db_password_secret_uuid" {}

# NEW: Secret version for the database password
resource "google_secret_manager_secret_version" "db_password_secret_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = var.db_password
}

# this null_resource will delete any existing service before we try to create a new one
resource "null_resource" "delete_old_run_service" {
  triggers = {
    service_name = var.service_name
    project      = var.project
    region       = var.region
  }

  provisioner "local-exec" {
    command = <<-EOT
      (
        # turn off “exit on any error”
        set +e
        if gcloud run services describe ${var.service_name} \
           --project=${var.project} --region=${var.region} &> /dev/null; then
          gcloud run services delete ${var.service_name} \
            --project=${var.project} --region=${var.region} --quiet
          else
            echo "Service ${var.service_name} not found — skipping deletion"
        fi
      ) || true
    EOT
  }
}

resource "google_cloud_run_service" "default" {
  name     = var.service_name
  location = var.region

  # force deletion of old service first
  depends_on = [
    null_resource.delete_old_run_service,
    google_project_service.run,
    google_project_service.artifact_registry,
    google_project_service.sqladmin, # NEW: Dependency on SQL Admin API
    google_project_service.secretmanager, # NEW: Dependency on Secret Manager API
    google_service_account_iam_member.run_sa_act_as,
    google_project_iam_member.cloud_run_cloudsql_client_role, # NEW: Dependency on Cloud SQL Client role
    google_secret_manager_secret.db_password_secret, # NEW: Dependency on secret creation
    google_secret_manager_secret_version.db_password_secret_version # NEW: Dependency on secret version creation
  ]

  template {
    metadata {
      annotations = {
        "deploymentTimestamp" = timestamp()
        # NEW: Annotation to map Secret Manager secret to an internal Kubernetes Secret
        # The format is "secret-<uuid>:<secret_resource_id>"
        "run.googleapis.com/secrets" = "secret-${random_uuid.db_password_secret_uuid.result}:${google_secret_manager_secret.db_password_secret.id}"
      }
    }
    spec {
      service_account_name = local.runtime_sa_email
      timeout_seconds = 300

      containers {
        image = var.image_url
        resources {
          limits = {
            memory = "512Mi"
            cpu    = "1"
          }
        }
        ports {
          container_port = 8443
        }
        # NEW: Environment variables for database connection (pointing to proxy)
        env {
          name  = "DB_HOST"
          value = "127.0.0.1" # Connect to the proxy on localhost
        }
        env {
          name  = "DB_PORT"
          value = "5432" # Standard PostgreSQL port
        }
        env {
          name  = "DB_USER"
          value = var.db_user
        }
        env {
          name  = "DB_NAME"
          value = var.db_name
        }
        env {
          name = "DB_PASSWORD"
          value_from {
            secret_key_ref {
              secret  = google_secret_manager_secret.db_password_secret.secret_id
              # Pin to a specific version for stability, or use "latest"
              version = google_secret_manager_secret_version.db_password_secret_version.version
              key     = google_secret_manager_secret_version.db_password_secret_version.version
              name    = "secret-${random_uuid.db_password_secret_uuid.result}"
            }
            }
          }
      }
      # --- Cloud SQL Auth Proxy Sidecar Container ---
      containers {
        name  = "cloudsql-proxy"
        image = "gcr.io/cloudsql-proxy/cloudsql-proxy:latest" # Recommended to pin to a specific version in production, e.g., :2.x.x

        args = [
          "--addr=127.0.0.1", # Proxy listens on localhost for the app container
          "--port=5432",      # Proxy listens on this port
          # Cloud SQL Instance Connection Name: PROJECT_ID:REGION:INSTANCE_NAME
          "${var.project}:${var.region}:${var.cloud_sql_instance_name}"
        ]

        ports {
          container_port = 5432 # Expose this port within the Cloud Run instance
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
    autogenerate_revision_name = true
}

# Allow unauthenticated invocations (public URL)
resource "google_cloud_run_service_iam_member" "invoker" {
  location = google_cloud_run_service.default.location
  project  = var.project
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}



















