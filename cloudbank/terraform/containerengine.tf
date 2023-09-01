resource oci_containerengine_cluster cloudbank {
  compartment_id = var.compartment_ocid
  defined_tags = {
  }
  endpoint_config {
    is_public_ip_enabled = "true"
    subnet_id = oci_core_subnet.regional_apiendpoint_subnet.id
  }
  freeform_tags = {
    "OKEclusterName" = "cloudbank"
  }
  image_policy_config {
    is_policy_enabled = "false"
  }
  kubernetes_version = local.latest
  name               = "cloudbank"
  options {
    add_ons {
      is_kubernetes_dashboard_enabled = "false"
      is_tiller_enabled               = "false"
    }
    admission_controller_options {
      is_pod_security_policy_enabled = "false"
    }
    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }

    service_lb_subnet_ids = [
      oci_core_subnet.regional_svclb_subnet.id,
    ]
  }
  vcn_id = data.oci_core_vcn.vcn.id
}


resource oci_containerengine_node_pool pool {
  cluster_id     = oci_containerengine_cluster.cloudbank.id
  compartment_id = var.compartment_ocid
  initial_node_labels {
    key   = "name"
    value = "cloudbank"
  }
  kubernetes_version = local.latest
  name               = "cloudbank-pool"
  node_config_details {
    placement_configs {
      availability_domain = data.oci_identity_availability_domain.ad1.name
      subnet_id = oci_core_subnet.regional_node_subnet.id
    }
    size = "2"
  }
  node_shape = var.instance_shape
  node_shape_config {
    memory_in_gbs = "16"
    ocpus         = "1"
  }
  node_source_details {
    image_id    = data.oci_core_images.instance_images.images[0].id
    source_type = "IMAGE"
  }
}

data "oci_containerengine_cluster_option" options {
  cluster_option_id = "all"
}

locals {
    versions = reverse(sort(data.oci_containerengine_cluster_option.options.kubernetes_versions))
    latest = local.versions[0]
  }

