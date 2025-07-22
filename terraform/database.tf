# This file is responsible for looking up the existing Cloud SQL instance.

# Look up the existing Cloud SQL for PostgreSQL instance by its name.
# This provides access to its properties, like the private IP address.
data "google_sql_database_instance" "main" {
  name    = var.db_instance_name
  project = var.gcp_project_id
}