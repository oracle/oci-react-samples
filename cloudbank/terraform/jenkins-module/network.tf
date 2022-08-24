resource oci_core_vcn jenkins_vcn {
  compartment_id = var.compartment_id
  cidr_block = var.vcn_cidr
  display_name = var.vcn_name
  dns_label = var.vcn_dns

  # if PreProvisioned VCN OCID is not null
  # do not provision a VCN, otherwise create jenkins_vcn
  count = var.preprovisioned_vcn_id != "" ? 0 : 1
}

resource oci_core_internet_gateway igw {
  compartment_id = var.compartment_id
  vcn_id = data.oci_core_vcn.vcn.id
  display_name = "${var.vcn_name}-igw"

  # if PreProvisioned VCN OCID is not null,
  # do not provision an IGW and reuse, otherwise create igw
  count = var.preprovisioned_vcn_id != "" ? 0 : 1
}

resource oci_core_route_table pub_rt {
  compartment_id = var.compartment_id
  vcn_id = data.oci_core_vcn.vcn.id
  display_name = "${var.vcn_name}-pub-rt"

  # if PreProvisioned IGW is not null,
  # tie route rule to preprovisioned IGW instead of the above IGW
  route_rules {
    destination = "0.0.0.0/0"
    network_entity_id = var.preprovisioned_igw_id != "" ? var.preprovisioned_igw_id : oci_core_internet_gateway.igw[0].id
  }
}

resource oci_core_security_list pub_sl_ssh {
  compartment_id = var.compartment_id
  display_name = "Allow Public SSH Connections to Jenkins"
  vcn_id = data.oci_core_vcn.vcn.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "6"
  }

  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

resource oci_core_security_list pub_sl_http {
  compartment_id = var.compartment_id
  display_name = "Allow HTTP(S) to Jenkins"
  vcn_id = data.oci_core_vcn.vcn.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "6"
  }

  ingress_security_rules {
    tcp_options {
      max = 80
      min = 80
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }

  ingress_security_rules {
    tcp_options {
      max = 443
      min = 443
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" pub_jenkins_subnet {
  compartment_id = var.compartment_id
  cidr_block = "10.0.30.0/28"
  display_name = "${var.vcn_name}-pub-subnet"

  vcn_id = data.oci_core_vcn.vcn.id
  route_table_id = oci_core_route_table.pub_rt.id
  security_list_ids = [oci_core_security_list.pub_sl_ssh.id, oci_core_security_list.pub_sl_http.id]
  dhcp_options_id = data.oci_core_vcn.vcn.default_dhcp_options_id

  dns_label = var.subnet_dns
}