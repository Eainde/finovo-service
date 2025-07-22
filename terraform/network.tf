# This file handles the networking configuration, including looking up the VPC
# and creating the Serverless VPC Access connector.

# Look up the existing VPC network by name.
data "google_compute_network" "main" {
  name    = var.existing_network_name
  project = var.gcp_project_id
}

# Create a Serverless VPC Access connector to allow Cloud Run to communicate
# with resources in the VPC network.
resource "google_vpc_access_connector" "main" {
  name          = "finovo-db-connector"
  # This CIDR range must be a /28 and must not overlap with any existing
  # subnets in your VPC.
  ip_cidr_range = "10.8.0.0/28"
  network       = data.google_compute_network.main.name
  region        = var.gcp_region
  project       = var.gcp_project_id
  min_instances = 2
  max_instances = 3
  depends_on    = [google_project_service.apis]
}