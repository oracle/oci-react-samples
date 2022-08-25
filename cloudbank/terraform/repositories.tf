resource "oci_artifacts_container_repository" backend {
  #Required
  compartment_id = var.compartment_ocid
  display_name = "cloudbank/${var.ocir_token}/transfer-springboot"
  is_public = true
}

resource "oci_artifacts_container_repository" frontend {
  #Required
  compartment_id = var.compartment_ocid
  display_name = "cloudbank/${var.ocir_token}/frontend-react-springboot"
  is_public = true
}