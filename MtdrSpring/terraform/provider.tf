terraform {
  required_providers{
    oci = {
      source = "hashicorp/oci"
      version = ">= 6.2.0"
    }
  }
}
provider "oci"{
  region = var.ociRegionIdentifier
}