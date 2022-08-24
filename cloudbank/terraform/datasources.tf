
data oci_core_images instance_images {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.instance_shape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

data oci_identity_availability_domains ADs {
  compartment_id = var.compartment_ocid
}


data "oci_core_services" "services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}


data oci_core_vcn vcn {
  # if there exists a preprovisioned VCN, use that VCN, otherwise, use jenkins_vcn
  vcn_id = var.preprovisioned_vcn_id != "" ? var.preprovisioned_vcn_id : oci_core_vcn.cloudbank_vcn[0].id
}