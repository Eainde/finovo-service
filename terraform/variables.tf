variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region (e.g., europe-west2)"
  type        = string
  default     = "europe-west2"
}

variable "image_url" {
  description = "Full Artifact Registry Docker image URL (incl. tag)"
  type        = string
}

variable "service_name" {
  description = "Name for the Cloud Run service"
  type        = string
  default     = "finovo-service"
}

variable "credentials_json" {
  description = "Path to the GCP service account key JSON file for Terraform authentication."
  type        = string
  sensitive   = true # Mark as sensitive
  # Consider using GOOGLE_APPLICATION_CREDENTIALS env var instead of hardcoding or file path for CI/CD
  # default = "/Users/akshaydipta/Downloads/finovo-466315-0e970e92573f.json"
}
variable "deployer_sa_email" {
  description = "The service account email used by CI to deploy (artifact-pusher@...)."
  type        = string
}

variable "cloud_sql_instance_name" {
  description = "The name of the Cloud SQL instance."
  type        = string
  default     = "finovo"
}

variable "db_name" {
  description = "The name of the database within the Cloud SQL instance."
  type        = string
  default     = "finovo"
}

variable "db_user" {
  description = "The database user."
  type        = string
  default     = "finovo"
}

variable "db_password" {
  description = "The database password. Store securely (e.g., in a .tfvars file or env var)."
  type        = string
  sensitive   = true # Mark as sensitive to prevent logging
  default     = "finovo" # REPLACE THIS WITH A SECURE PASSWORD OR USE A .tfvars FILE
}
