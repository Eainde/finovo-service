# This file contains the main provider configuration and enables the necessary GCP APIs.
terraform {
  # This tells Terraform to store its state file in a GCS bucket, allowing
  # state to be shared between GitHub Actions runs.
  backend "gcs" {
    bucket = "finovo-466315-tfstate" # This is the bucket created by the backend_setup.tf script.
    prefix = "finovo-service/state"
  }
}

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
  disable_on_destroy = false
}