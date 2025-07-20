terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Ensure this matches your provider version
    }
    random = { # Add this provider if you don't have it already for random_uuid
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Configure the GCS backend
  backend "gcs" {
    bucket = "finovo-bucket" # Choose a unique bucket name
    prefix = "terraform/state"                   # Optional: prefix for your state files
  }
}
