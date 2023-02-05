provider "google" {
  project = var.project
  region  = var.region
}

terraform {
  cloud {
    organization = "beranm"

    workspaces {
      name = "tacr_infrastructure"
    }
  }
}