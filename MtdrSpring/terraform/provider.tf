terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = ">= 5.9.0"
    }
  }
}

provider "oci"{
  region = var.ociRegionIdentifier
}