data oci_objectstorage_namespace namespace {
  #Required
  compartment_id = var.ociCompartmentOcid
}

resource "oci_objectstorage_bucket" dbbucket {
  #Required
  namespace = data.oci_objectstorage_namespace.namespace.namespace
  compartment_id = var.ociCompartmentOcid
  name = "${var.runName}-${var.mtdrKey}"
}