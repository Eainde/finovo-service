# This file handles all Identity and Access Management (IAM) permissions.

# Grant the Cloud Run Invoker role to 'allUsers' to make the service publicly accessible.
# Remove this block if you want the service to be private.
resource "google_cloud_run_v2_service_iam_binding" "allow_public" {
  project  = google_cloud_run_v2_service.main.project
  location = google_cloud_run_v2_service.main.location
  name     = google_cloud_run_v2_service.main.name
  role     = "roles/run.invoker"
  members = [
    "allUsers",
  ]
}

# Grant the Cloud Run service's service account permission to access the database password secret.
resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  project   = google_secret_manager_secret.db_password.project
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  # The service account is implicitly created for the Cloud Run service.
  member    = "serviceAccount:${google_cloud_run_v2_service.main.template.service_account}"
}