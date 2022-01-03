resource "oci_containerengine_cluster" "mtdrworkshopcluster"{
    #Required
    compartment_id      = var.ociCompartmentOcid
    kubernetes_version  = "v1.21.5"
    name                = "mtdrworkshopcluster"
    vcn_id              = "oci_core_vcn.okevcn.id"
    #optional
    endpoint_config{
        #optional
        is_public_ip_enabled = "true"
        nsg_id=[
        ]
        subnet_id = oci_core_subnet.endpoint_Subnet.id
    }
    options{
        service_lb_subnet_ids = [oci_core_subnet.svclb_Subnet.id]

        add_ons {
            #Optional
            is_kubernetes_dashboard_enabled = "false"
            is_tiller_enabled               = "false"
        }
        admission_controller_options {
            #Optional
            is_pod_security_policy_enabled = "false"   
        }
        kubernetes_network_config{
            #Optional
            pods_cidr                      = "10.244.0.0/16"
            services_cidr                  = "10.96.0.0/16"
        }
    }
}
resource "oci_containerengine_node_pool" "okell_node_pool"{
    
}