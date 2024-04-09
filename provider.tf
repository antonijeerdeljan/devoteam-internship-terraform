terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.23.0"
    }
  }

  backend "gcs" {
    bucket = "devoteam-app"
    prefix  = "terraform/state"
  }

}

provider "google" {
  project     = var.project
  region      = var.project
  zone        = var.zone
  #credentials = var.gcp_credentials
}