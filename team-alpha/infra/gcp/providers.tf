terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # matches the constraint in the shared modules
    }
  }
}

provider "google" {
  region = "europe-west4"
  # no project set here on purpose - each request names its own project_id.
  # nothing applies this in the demo - CI only runs fmt/validate.
}
