variable "gcp_project_id" {
  description = "The GCP project ID where resources will be deployed."
  type        = string
}

variable "gcp_region" {
  description = "The GCP region for deploying resources."
  type        = string
  default     = "europe-west2"
}

variable "existing_network_name" {
  description = "The name of the existing VPC network to use for the connection."
  type        = string
  default     = "default" # Change this if you are not using the 'default' VPC.
}

variable "db_instance_name" {
  description = "The name of your existing Cloud SQL instance."
  type        = string
  default     = "finovo"
}

variable "db_name" {
  description = "The name of the PostgreSQL database within the Cloud SQL instance."
  type        = string
  default     = "finovo"
}

variable "db_user" {
  description = "The existing username for the PostgreSQL database."
  type        = string
  default     = "finovo"
}

variable "db_pass" {
  description = "The password for the existing PostgreSQL database user. This is sensitive."
  type        = string
  sensitive   = true
  default     = "finovo" # Change this to your actual database password
}

variable "existing_repo_name" {
  description = "The name of the existing Artifact Registry repository."
  type        = string
  default     = "docker-repo" # Change this to the name of your repository
}

variable "image_url" {
  description = "Full Artifact Registry Docker image URL (incl. tag)"
  type        = string
}
