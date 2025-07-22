# This file manages the database password using Google Secret Manager.

# Create a Secret Manager secret to store the database password.
resource "google_secret_manager_secret" "db_password" {
  secret_id = var.db_user # Naming the secret after the user for clarity.
  project   = var.gcp_project_id
  replication {
  }
}

# Create a version for the secret with the actual password value.
resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_pass
}