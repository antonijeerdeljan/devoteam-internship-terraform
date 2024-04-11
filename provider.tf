terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.24.0"
    }
  }

  backend "gcs" {
    bucket = "devoteam-terraform-state"
    prefix  = "terraform/state"
  }

}

provider "google" {
  project     = var.project
  region      = var.project
  zone        = var.zone
}