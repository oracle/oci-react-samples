resource oci_core_internet_gateway igw {
  compartment_id = var.compartment_ocid
  display_name = "cloudbank-igw-cloudbank"
  enabled      = "true"
  vcn_id = data.oci_core_vcn.vcn.id
}

resource oci_core_service_gateway sgw {
  compartment_id = var.compartment_ocid
  display_name = "cloudbank-sgw"
  services {
    service_id = data.oci_core_services.services.services.0.id
  }
  vcn_id = data.oci_core_vcn.vcn.id
}

resource oci_core_subnet regional_node_subnet {
  cidr_block     = "10.0.10.0/24"
  compartment_id = var.compartment_ocid
  dhcp_options_id =  data.oci_core_vcn.vcn.default_dhcp_options_id
  display_name    = "cloudbank-regional-node-subnet"
  dns_label       = "cbnodesubnet"

  prohibit_internet_ingress  = "true"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.oke-private-rt.id
  security_list_ids = [
    oci_core_security_list.node_security_list.id,
  ]
  vcn_id = data.oci_core_vcn.vcn.id
}

resource oci_core_subnet regional_apiendpoint_subnet {
  cidr_block     = "10.0.0.0/28"
  compartment_id = var.compartment_ocid
  defined_tags = {
  }
  dhcp_options_id = data.oci_core_vcn.vcn.default_dhcp_options_id
  display_name    = "cloudbank-regional-api-endpoint-subnet"
  dns_label       = "cbapisubnet"
  freeform_tags = {
  }
  ipv6cidr_blocks = [
  ]
  prohibit_internet_ingress  = "false"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = data.oci_core_vcn.vcn.default_route_table_id
  security_list_ids = [
    oci_core_security_list.cloudbank-oke-k8sApiEndpoint.id,
  ]
  vcn_id = data.oci_core_vcn.vcn.id
}

resource oci_core_subnet regional_svclb_subnet {
  cidr_block     = "10.0.20.0/24"
  compartment_id = var.compartment_ocid

  dhcp_options_id = data.oci_core_vcn.vcn.default_dhcp_options_id
  display_name    = "cloudbank-regional-svclb-subnet"
  dns_label       = "cbsvclbsubnet"

  ipv6cidr_blocks = [
  ]
  prohibit_internet_ingress  = "false"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = data.oci_core_vcn.vcn.default_route_table_id
  security_list_ids = [
    data.oci_core_vcn.vcn.default_security_list_id,
  ]
  vcn_id = data.oci_core_vcn.vcn.id
}

resource oci_core_vcn cloudbank_vcn {
  cidr_blocks = [
    "10.0.0.0/16",
  ]
  compartment_id = var.compartment_ocid
  display_name = "cloudbank-oke-vcn"
  dns_label    = "cloudbank"

  ipv6private_cidr_blocks = [
  ]

  # if there exists a preprovisioned_vcn, provision nothing
  # otherwise, provision cloudbank_vcn
  count = var.preprovisioned_vcn_id != "" ? 0 : 1
}

resource oci_core_default_dhcp_options default_dhcp_options {
  compartment_id = var.compartment_ocid
  display_name     = "cloudbank-vcn-default-dhcp"
  domain_name_type = "CUSTOM_DOMAIN"
  manage_default_resource_id = data.oci_core_vcn.vcn.default_dhcp_options_id
  options {
    custom_dns_servers = [
    ]
    server_type = "VcnLocalPlusInternet"
    type        = "DomainNameServer"
  }
  options {
    search_domain_names = [
      "cloudbank.oraclevcn.com",
    ]
    type = "SearchDomain"
  }
}

resource oci_core_nat_gateway oke-ngw {
  block_traffic  = false
  compartment_id = var.compartment_ocid

  display_name = "cloudbank-ngw"
  vcn_id       = data.oci_core_vcn.vcn.id
}

resource oci_core_route_table oke-private-rt {
  compartment_id = var.compartment_ocid
  display_name = "cloudbank-private-rt"

  route_rules {
    description       = "traffic to the internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.oke-ngw.id
  }
  route_rules {
    description       = "traffic to OCI services"
    destination       = data.oci_core_services.services.services.0.cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.id
  }
  vcn_id = data.oci_core_vcn.vcn.id
}

resource oci_core_default_route_table export_oke-public-routetable {
  compartment_id = var.compartment_ocid
  defined_tags = {
  }
  display_name = "cloudbank-public-rt"
  freeform_tags = {
  }
  manage_default_resource_id = data.oci_core_vcn.vcn.default_route_table_id
  route_rules {
    description       = "traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource oci_core_security_list cloudbank-oke-k8sApiEndpoint {
  compartment_id = var.compartment_ocid
  defined_tags = {
  }
  display_name = "cloudbank-oke-apiep-sl"
  egress_security_rules {
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    destination      =  data.oci_core_services.services.services.0.cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "443"
      min = "443"
    }
  }
  egress_security_rules {
    description      = "All traffic to worker nodes"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  freeform_tags = {
  }
  ingress_security_rules {
    description = "External access to Kubernetes API endpoint"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }
  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    protocol    = "6"
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }
  ingress_security_rules {
    description = "Kubernetes worker to control plane communication"
    protocol    = "6"
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "12250"
      min = "12250"
    }
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  vcn_id = data.oci_core_vcn.vcn.id
}

resource oci_core_security_list node_security_list {
  compartment_id = var.compartment_ocid
  defined_tags = {
  }
  display_name = "cloudbank-oke-node-sl"
  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Access to Kubernetes API Endpoint"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }
  egress_security_rules {
    description      = "Kubernetes worker to control plane communication"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "12250"
      min = "12250"
    }
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    destination      = data.oci_core_services.services.services.0.cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "443"
      min = "443"
    }
  }
  egress_security_rules {
    description      = "ICMP Access from Kubernetes Control Plane"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Worker Nodes access to Internet"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
  }
  freeform_tags = {
  }
  ingress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    protocol    = "all"
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.0.0/28"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "TCP access from Kubernetes Control Plane"
    protocol    = "6"
    source      = "10.0.0.0/28"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Inbound SSH traffic to worker nodes"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
  vcn_id = data.oci_core_vcn.vcn.id
}

resource oci_core_default_security_list export_oke-svclbseclist {
  compartment_id = var.compartment_ocid
  display_name = "cloudbank-oke-svclb"

  manage_default_resource_id = data.oci_core_vcn.vcn.default_security_list_id
}

