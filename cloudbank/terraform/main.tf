
module jenkins-build {
  source = "./jenkins-module"
  compartment_id     = var.compartment_ocid
  jenkins_password   = var.jenkins_password
  region             = var.region

  # preprovisioned_VCN
  preprovisioned_vcn_id = var.preprovisioned_vcn_id

  # Reuse IGW if there exists a preprovisioned VCN
  preprovisioned_igw_id = var.preprovisioned_vcn_id != "" ? oci_core_internet_gateway.igw.id : ""

#  unique_agent_names = ["agent1"] # Only one agent
}