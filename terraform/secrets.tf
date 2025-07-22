# This file manages the database password using Google Secret Manager.

# Create a Secret Manager secret to store the database password.
data "google_secret_manager_secret" "db_password" {
  secret_id = "${var.db_user}-password"
  project   = var.gcp_project_id
}