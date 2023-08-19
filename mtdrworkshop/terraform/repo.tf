resource "oci_artifacts_container_repository" frontend {
  #Required
  compartment_id = var.ociCompartmentOcid
  display_name = "${var.runName}/next-frontendapp"
  is_public = true
}

resource "oci_artifacts_container_repository" backend {
  #Required
  compartment_id = var.ociCompartmentOcid
  display_name = "${var.runName}/todolistapp-helidon-se"
  is_public = true
}