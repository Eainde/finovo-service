# File: wif_setup.tf
#
# This configuration creates the necessary GCP resources to allow your
# GitHub Actions workflow to securely authenticate with Google Cloud
# using an existing Service Account.
#
# You only need to run this once.

provider "google" {
  # This will use your local gcloud credentials when you run it.
}

variable "gcp_project_id" {
  description = "The GCP project ID where you want to create the identity pool."
  type        = string
  default     = "finovo-466315"
}

variable "github_repository" {
  description = "Your GitHub repository in 'owner/repo' format (e.g., 'my-org/my-cool-app')."
  type        = string
  default     = "Eainde/finovo-service"
}

variable "existing_sa_email" {
  description = "The email address of your existing Google Cloud Service Account."
  type        = string
  default     = "artifact-pusher@finovo-466315.iam.gserviceaccount.com"
}

variable "pool_id" {
  description = "A unique ID for the Workload Identity Pool."
  type        = string
  default     = "github-actions-pool-finovo-1" # Using a new, unique name to avoid conflicts.
}

variable "provider_id" {
  description = "A unique ID for the Workload Identity Pool Provider."
  type        = string
  default     = "github-provider-finovo-1"
}

# 1. Look up your existing Service Account.
data "google_service_account" "existing_sa" {
  account_id = split("@", var.existing_sa_email)[0]
  project    = var.gcp_project_id
}

# 2. Create the Workload Identity Pool.
# We are using a new, unique name to bypass any issues with the old pool.
resource "google_iam_workload_identity_pool" "main" {
  project                   = var.gcp_project_id
  workload_identity_pool_id = var.pool_id
  display_name              = "Pool for GitHub Actions (Finovo)"
}

# 3. Create the OIDC Provider within the pool.
resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.gcp_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.main.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "GitHub OIDC Provider (Finovo)"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  # CORRECTED: Added an attribute condition to explicitly scope this provider
  # to a specific GitHub repository, which resolves the API error.
  attribute_condition = "attribute.repository == '${var.github_repository}'"
}

# 4. Allow your GitHub repository to impersonate your existing Service Account.
resource "google_service_account_iam_member" "impersonate" {
  service_account_id = data.google_service_account.existing_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.main.name}/attribute.repository/${var.github_repository}"
}

# 5. Ensure your existing Service Account has the necessary roles.
resource "google_project_iam_member" "sa_roles" {
  for_each = toset([
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/vpcaccess.user",
    "roles/cloudsql.client",
    "roles/secretmanager.admin",
    "roles/artifactregistry.reader"
  ])
  project = var.gcp_project_id
  role    = each.key
  member  = "serviceAccount:${var.existing_sa_email}"
}

output "workload_identity_provider_name" {
  description = "The full name of the WIF provider to use in your GitHub Actions workflow."
  value       = google_iam_workload_identity_pool_provider.github.name
}