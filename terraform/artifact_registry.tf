# This file defines the Artifact Registry repository for storing Docker images.

# Look up the existing Artifact Registry Docker repository.
data "google_artifact_registry_repository" "main" {
  location      = var.gcp_region
  repository_id = var.existing_repo_name
  project       = var.gcp_project_id
}