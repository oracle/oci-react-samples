data "oci_identity_availability_domain" ad1 {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}