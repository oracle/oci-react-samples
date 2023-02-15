#networking resources for OKE
resource "oci_core_vcn" "okevcn" {
  cidr_block      = "10.0.0.0/16"
  compartment_id  = var.ociCompartmentOcid
  display_name    = "mtdrworkshop-${var.mtdrKey}"
  dns_label       = "mtdrworkshop"
}
resource "oci_core_internet_gateway" "igw" {
  compartment_id  = var.ociCompartmentOcid
  display_name    = "ClusterInternetGateway"
  vcn_id          = oci_core_vcn.okevcn.id
}

resource "oci_core_nat_gateway" "ngw" {
  #Required
  compartment_id  = var.ociCompartmentOcid
  vcn_id          = oci_core_vcn.okevcn.id
  #optional
  block_traffic   = "false"
  freeform_tags = {

  }
  display_name = "ngw"
}
resource "oci_core_service_gateway" "sgw" {
  #required
  compartment_id  = var.ociCompartmentOcid
  services {
    service_id  = data.oci_core_services.services.services.0.id
  }
  vcn_id = oci_core_vcn.okevcn.id
  #optional
  display_name = "mtdr_sgw"
}

resource "oci_core_route_table" "private" {
  #required
  compartment_id  = var.ociCompartmentOcid
  vcn_id          = oci_core_vcn.okevcn.id
  #optional
  display_name    = "private"
  route_rules {
    #required
    network_entity_id   = oci_core_nat_gateway.ngw.id
    #optional
    description         = "Traffic to the internet"
    destination         = "0.0.0.0/0"
    destination_type    = "CIDR_BLOCK"
  }
  route_rules {
    #required
    network_entity_id   = oci_core_service_gateway.sgw.id
    #optional
    description         = "Traffic to OCI Services"
    destination         = data.oci_core_services.services.services.0.cidr_block
    destination_type    = "SERVICE_CIDR_BLOCK"
  }
}
## default route table
resource "oci_core_default_route_table" "public" {
  display_name = "public"
  freeform_tags = {
  }
  manage_default_resource_id = oci_core_vcn.okevcn.default_route_table_id
  route_rules {
    description       = "traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}
# resource "oci_core_route_table" "public"{
#     #required
#     compartment_id  = var.ociCompartmentOcid
#     vcn_id          = oci_core_vcn.okevcn.id
#     #optional
#     display_name = "public"
#     route_rules {
#         #required
#         network_entity_id   = oci_core_service_gateway.igw.id
#         #optional
#         description         = "Traffic to/from internet"
#         destination         = "0.0.0.0/0"
#         destination_type    = "CIDR_BLOCK"
#     }
# }

resource "oci_core_subnet" "endpoint" {
  #required
  cidr_block                  = "10.0.0.0/28"
  compartment_id              = var.ociCompartmentOcid
  vcn_id                      = oci_core_vcn.okevcn.id
  #optional
  security_list_ids           = [oci_core_security_list.endpoint.id]
  display_name                = "subnet1ForNodePool"
  prohibit_public_ip_on_vnic  = "false"
  route_table_id              = oci_core_vcn.okevcn.default_route_table_id
  dns_label                   = "endpoint"
}
#ApiEndpoint security list
resource "oci_core_security_list" "endpoint" {
  #required
  compartment_id  = var.ociCompartmentOcid
  vcn_id          = oci_core_vcn.okevcn.id
  #Optional
  display_name    = "endpoint"
  egress_security_rules {
    #Required
    destination         = data.oci_core_services.services.services.0.cidr_block
    protocol            = "6" #TCP
    #optional
    destination_type    = "SERVICE_CIDR_BLOCK"
    description         = "Allow Kubernetes Control Plane to communicate with OKE"
    stateless           = "false"
    tcp_options {
      max = "443"
      min = "443"
    }
  }
  egress_security_rules {
    #required
    destination         = "10.0.10.0/24"
    protocol            = "6" #TCP
    #optional
    destination_type    = "CIDR_BLOCK"
    description         = "All traffic to worker nodes"
    stateless           = "false"
  }
  egress_security_rules {
    #required
    destination         = "10.0.10.0/24"
    protocol            = "1" #ICMP
    #optional
    destination_type    = "CIDR_BLOCK"
    description         = "Path Discovery"
    icmp_options {
      type = "3"
      code = "4"
    }
    stateless = "false"
  }
  ingress_security_rules {
    #required
    source              = "0.0.0.0/0"
    protocol            = "6" #TCP
    #optional
    source_type         = "CIDR_BLOCK"
    stateless           = "false"
    description         = "External access to Kubernetes API Endpoint"
    tcp_options {
      max = "6443"
      min = "6443"
    }

  }
  ingress_security_rules {
    #required
    source              = "10.0.10.0/24"
    protocol            = "6"
    #optional
    source_type         = "CIDR_BLOCK"
    stateless           = "false"
    description         = "Kubernetes worker to Kubernetes API endpoint communication"
    tcp_options{
      max = "6443"
      min = "6443"
    }
  }
  ingress_security_rules {
    #required
    source              = "10.0.10.0/24"
    protocol            = "6"
    #optional
    source_type         = "CIDR_BLOCK"
    stateless           = "false"
    description         = "Kubernetes woker to control plane communication"
    tcp_options {
      max = "12250"
      min = "12250"
    }
  }
  ingress_security_rules {
    #required
    source              = "10.0.10.0/24"
    protocol            = "1" #ICMP
    #optional
    source_type         = "CIDR_BLOCK"
    stateless           = "false"
    description         = "Path Discovery"
    icmp_options {
      type = "3"
      code = "4"
    }
  }
}
resource "oci_core_subnet" "nodePool_Subnet" {
  #Required
  #availability_domain = data.oci_identity_availability_domain.ad1.name
  cidr_block          = "10.0.10.0/24"
  compartment_id      = var.ociCompartmentOcid
  vcn_id              = oci_core_vcn.okevcn.id
  # Provider code tries to maintain compatibility with old versions.
  security_list_ids = [oci_core_security_list.nodePool.id]
  display_name      = "SubNet1ForNodePool"
  prohibit_public_ip_on_vnic = "true"
  route_table_id    = oci_core_route_table.private.id
  dns_label           = "nodepool"
}
#nodepool security list
resource "oci_core_security_list" "nodePool" {
  #required
  compartment_id  = var.ociCompartmentOcid
  vcn_id          = oci_core_vcn.okevcn.id
  #Optional
  display_name    = "nodepool"
  egress_security_rules {
    #Required
    destination         = "10.0.10.0/24"
    protocol            = "all"
    #optional
    destination_type    = "CIDR_BLOCK"
    description         = "Allow pods on one worker node to communicate with pods on other worker nodes"
    stateless           = "false"
  }
  egress_security_rules {
    #required
    destination         = "10.0.0.0/28"
    protocol            = "6" #TCP
    #optional
    destination_type    = "CIDR_BLOCK"
    description         = "Access to Kubernetes API endpoint"
    tcp_options {
      min = "6443"
      max = "6443"
    }
    stateless           = "false"
  }
  egress_security_rules {
    #required
    destination         = "10.0.0.0/28"
    protocol            = "6" #TCP
    #optional
    destination_type    = "CIDR_BLOCK"
    description         = "Kubernetes worker to control plane communication"
    tcp_options {
      max = "12250"
      min = "12250"
    }
    stateless = "false"
  }
  egress_security_rules {
    #Required
    destination         = "10.0.0.0/28"
    protocol            = "1" #ICMP
    #optional
    destination_type    = "CIDR_BLOCK"
    description         = "Path Discovery"
    icmp_options {
      type = "3"
      code = "4"
    }
    stateless           = "false"
  }
  egress_security_rules {
    #required
    destination         = data.oci_core_services.services.services.0.cidr_block
    protocol            = "6" #TCP
    #optional
    destination_type    = "SERVICE_CIDR_BLOCK"
    description         = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    tcp_options {
      max = "443"
      min = "443"
    }
    stateless           = "false"
  }
  egress_security_rules {
    #required
    destination         = "0.0.0.0/0"
    protocol            = "1" #ICMP
    #optional
    destination_type    = "CIDR_BLOCK"
    description         = "ICMP Access from Kubernetes Control Plane"
    icmp_options {
      type = "3"
      code = "4"
    }
    stateless = "false"
  }
  egress_security_rules {
    #required
    destination         = "0.0.0.0/0"
    protocol            = "all" #ICMP
    #optional
    destination_type    = "CIDR_BLOCK"
    description         = "Worker Nodes access to Internet"
    stateless = "false"
  }
  ingress_security_rules {
    #required
    source              = "0.0.0.0/0"
    protocol            = "6" #TCP
    #optional
    source_type         = "CIDR_BLOCK"
    stateless           = "false"
    description         = "External access to Kubernetes API Endpoint"
    tcp_options {
      max = "6443"
      min = "6443"
    }

  }
  ingress_security_rules {
    #required
    source              = "10.0.10.0/24"
    protocol            = "all"
    #optional
    source_type         = "CIDR_BLOCK"
    stateless           = "false"
    description         = "Allow pods on one worker node to communicate with pods on other worker nodes"
  }
  ingress_security_rules {
    #required
    source              = "10.0.0.0/28"
    protocol            = "1"#ICMP
    #optional
    source_type         = "CIDR_BLOCK"
    stateless           = "false"
    description         = "Path Discovery"
    icmp_options {
      type = "3"
      code = "4"
    }
  }
  ingress_security_rules {
    #required
    source              = "10.0.0.0/28"
    protocol            = "6" #TCP
    #optional
    source_type         = "CIDR_BLOCK"
    stateless           = "false"
    description         = "TCP access from Kubernetes Control Plane"
  }
  ingress_security_rules {
    #required
    source              = "0.0.0.0/0"
    protocol            = "6" #TCP
    #optional
    source_type         = "CIDR_BLOCK"
    stateless           = "false"
    description         = "Inbound SSH traffic to worker nodes"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
}
# resource "oci_core_subnet" "svclb_Subnet" {
#   #Required
#   #availability_domain = data.oci_identity_availability_domain.ad1.name
#   cidr_block          = "10.0.20.0/24"
#   compartment_id      = var.ociCompartmentOcid
#   vcn_id              = oci_core_vcn.okevcn.id
#   # Provider code tries to maintain compatibility with old versions.
#   security_list_ids = [oci_core_default_security_list.svcLB.id]
#   display_name      = "SubNet1ForSvcLB"
#   route_table_id    = oci_core_vcn.okevcn.default_route_table_id
#   dhcp_options_id = oci_core_vcn.okevcn.default_dhcp_options_id
#   prohibit_public_ip_on_vnic = "false"
#   dns_label           = "svclb"
# }

resource "oci_core_security_list" "svclb_sl" {
  #required
  compartment_id  = var.ociCompartmentOcid
  vcn_id          = oci_core_vcn.okevcn.id
  #Optional
  display_name    = "scvlb"
  egress_security_rules {
    #Required
    destination         = "0.0.0.0/0"
    protocol            = "6" #TCP
    #optional
    destination_type    = "CIDR_BLOCK"
    stateless           = "false"
  }
  ingress_security_rules {
    #required
    source              = "0.0.0.0/0"
    protocol            = "6" #TCP
    #optional
    source_type         = "CIDR_BLOCK"
    stateless           = "false"
  }
}
resource "oci_core_subnet" "svclb_Subnet" {
  #Required
  #availability_domain = data.oci_identity_availability_domain.ad1.name
  cidr_block          = "10.0.20.0/24"
  compartment_id      = var.ociCompartmentOcid
  vcn_id              = oci_core_vcn.okevcn.id
  display_name        = "Subnet1 for svclb"
  # Provider code tries to maintain compatibility with old versions.
  security_list_ids = [oci_core_security_list.svclb_sl.id]
  route_table_id    = oci_core_vcn.okevcn.default_route_table_id
  dhcp_options_id = oci_core_vcn.okevcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = "false"
  dns_label           = "svclb"
}


#default security list for svcLB
# resource oci_core_default_security_list svcLB {
#   display_name = "svcLB"
#   manage_default_resource_id = oci_core_vcn.okevcn.default_security_list_id
# }
data "oci_core_services" "services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}