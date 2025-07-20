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
}

resource "google_project_service" "artifact_registry" {
  service = "artifactregistry.googleapis.com"
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
    google_service_account_iam_member.run_sa_act_as
  ]

  template {
    metadata {
      annotations = {
        "deploymentTimestamp" = timestamp()
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
