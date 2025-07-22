#
# This configuration creates the necessary GCP resources to allow your
# GitHub Actions workflow to securely authenticate with Google Cloud
# using an existing Service Account.
#
# You only need to run this once.
# 1. Look up your existing Service Account.
data "google_service_account" "existing_sa" {
  account_id = split("@", var.existing_sa_email)[0]
  project    = var.gcp_project_id
}

# 2. Create the Workload Identity Pool.
# This will be the "github-actions-pool" that your workflow is looking for.
resource "google_iam_workload_identity_pool" "main" {
  project                   = var.gcp_project_id
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "Pool for GitHub Actions"
}

# 3. Create the OIDC Provider within the pool.
# This will be the "github-provider" that your workflow is looking for.
resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.gcp_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.main.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub OIDC Provider"

  # CORRECTED: The issuer_uri must be inside an 'oidc' block.
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
}

# 4. Allow your GitHub repository to impersonate your existing Service Account.
# This creates the binding between GitHub and your GCP Service Account.
resource "google_service_account_iam_member" "impersonate" {
  service_account_id = data.google_service_account.existing_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.main.name}/attribute.repository/${var.github_repository}"
}

# 5. Ensure your existing Service Account has the necessary roles to run your main Terraform files.
# If the SA already has these roles, Terraform will not make any changes.
resource "google_project_iam_member" "sa_roles" {
  for_each = toset([
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/vpcaccess.user",
    "roles/sql.client",
    "roles/secretmanager.admin",
    "roles/artifactregistry.reader"
  ])
  project = var.gcp_project_id
  role    = each.key
  member  = "serviceAccount:${var.existing_sa_email}"
}
