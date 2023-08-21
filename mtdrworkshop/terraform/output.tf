output "cluster_versions" {
    oci_containerengine_cluster.mtdrworkshop_cluster.kubernetes_version
}

output "pool_versions" {
    oci_containerengine_node_pool.oke_node_pool.kubernetes_version
}