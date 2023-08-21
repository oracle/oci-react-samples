output "cluster_versions" {
    value = oci_containerengine_cluster.mtdrworkshop_cluster.kubernetes_version
}

output "pool_versions" {
    value = oci_containerengine_node_pool.oke_node_pool.kubernetes_version
}