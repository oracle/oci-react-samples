#No longer creating API_gateway

#resource "oci_apigateway_gateway" "todolist"{
#  #required
#  compartment_id = var.ociCompartmentOcid
#  endpoint_type = "PUBLIC"
#  subnet_id = oci_core_subnet.svclb_Subnet.id
#  display_name = "todolist"
#}