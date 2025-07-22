# This file defines the Google Cloud Run service.

# Create the Cloud Run service, which will run the containerized application.
resource "google_cloud_run_v2_service" "main" {
  name     = "finovo-service"
  location = var.gcp_region
  project  = var.gcp_project_id
  deletion_protection = false

  # The template defines the configuration for new revisions of the service.
  template {
    containers {
      image = var.image_url
      ports {
        container_port = 8443
      }

      # Environment variables passed to the container.
      # The database credentials are provided securely.
      env {
        name  = "DB_HOST"
        value = data.google_sql_database_instance.main.private_ip_address
      }
      env {
        name  = "DB_PORT"
        value = "5432"
      }
      env {
        name  = "DB_NAME"
        value = var.db_name
      }
      env {
        name  = "DB_USER"
        value = var.db_user
      }
      env {
        name = "DB_PASS"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "1"
          }
        }
      }
    }

    # Connect the Cloud Run service to the VPC network.
    vpc_access {
      connector = google_vpc_access_connector.main.id
      egress    = "ALL_TRAFFIC" # Allows all outbound traffic to go through the VPC.
    }
  }

  # Direct 100% of traffic to the latest revision.
  traffic {
    percent         = 100
    type            = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  depends_on = [
    google_project_service.apis,
  ]
}