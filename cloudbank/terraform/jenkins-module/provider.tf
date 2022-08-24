terraform {
    required_providers {
        oci = {
            source  = "oracle/oci"
            version = ">= 4.80.1"
        }
    }
}

provider oci {
  region = var.region
}
