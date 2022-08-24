# Optional, but important, if empty, will provision a new Internet Gateway, will reuse the gateway below otherwise
variable preprovisioned_igw_id {
  description = "OCID of preprovisioned Internet Gateway"
  default = ""
}

# Optional, but important, if empty, will create 2 VCNs (For OKE and Jenkins)
variable preprovisioned_vcn_id {
  description = "OCID of preprovisioned VCN"
  default = ""
}
# Required
variable region {
  description = "Tenancy region to provision resources in"
}
# Required
variable compartment_id {
  description = "OCID of compartment to provision resources in"
}
variable availability_domain_name {
  description = "Availability Domain to provision the compute instance in"
  default = null
}

variable instance_shape {
  description = "Shape of Jenkins VM compute instance to provision and install Jenkins in"
  default = "VM.Standard.E3.Flex"
}
variable instance_ocpus {
  description = "Number of OCPUs the Jenkins VM compute instance will have"
  default = 1
}
variable instance_shape_config_memory_in_gbs {
  description = ""
  default = 16
}
variable instance_os {
  description = "Operating system of Jenkins VM compute instance"
  default     = "Oracle Linux"
}

variable linux_os_version {
  description = "Operating system version"
  default     = "7.9"
}

variable jenkins_user {
  description = "The username for Jenkins admin user"
  type = string
  default     = "admin"
}
# Required
variable jenkins_password {
  description = "Password for Jenkins admin user"
  type = string
  sensitive = true
}
variable generate_public_ssh_key {
  default = true
}
variable public_ssh_key {
  default = ""
}
variable vcn_name {
  default = "jenkins-vcn"
}
variable vcn_cidr {
  description = "VCN CIDR IP Block"
  default     = "10.0.0.0/16"
}
variable vcn_dns {
  description = "VCN subnet DNS record"
  default = "jnknsvcn"
}
variable subnet_dns {
  description = "VCN subnet DNS record"
  default = "jnknsappsub"
}

locals {
  availability_domain_name   = var.availability_domain_name != null ? var.availability_domain_name : data.oci_identity_availability_domains.ADs.availability_domains[0].name
  instance_shape             = var.instance_shape
  compute_flexible_shapes    = ["VM.Standard.E3.Flex","VM.Standard.E4.Flex"]
  is_flexible_instance_shape = contains(local.compute_flexible_shapes, local.instance_shape)
}
