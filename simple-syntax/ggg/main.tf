terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.67.0"
    }
  }
}

provider "google" {
  project = "elegant-tide-343005"
  region = "asia-south1"
}

