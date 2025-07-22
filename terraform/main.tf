# This file contains the main provider configuration and enables the necessary GCP APIs.
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Enable all necessary Google Cloud APIs for the project.
# This ensures that all required services are active before creating resources.
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "vpcaccess.googleapis.com",
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "secretmanager.googleapis.com"
  ])
  project                    = var.gcp_project_id
  service                    = each.key
  #disable_dependency_violation = true # Prevents errors if APIs are already enabled.
}