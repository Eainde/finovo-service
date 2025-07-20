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
  type = string
}
variable "deployer_sa_email" {
  description = "The service account email used by CI to deploy (artifact-pusher@...)."
  type        = string
}