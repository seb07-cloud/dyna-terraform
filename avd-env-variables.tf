variable "avd_rg_name" {
  type        = string
  description = "This is the AVD resource group"
}

variable "inf_rg_name" {
  type        = string
  description = "This is the Infrastructure AVD resource group"
}

variable "avd_rg_location" {
  type        = string
  description = "This is the AVD resource groups location"
}

variable "aad_group_name" {
  type        = string
  description = "Which group do you like to assign"
}

variable "init_rg_name" {
  type        = string
  description = "This is resource group where the initial VM for image creation lives"
}

variable "init_vm_name" {
  type        = string
  description = "How is the initial VM for image creation called"
}

variable "vnet_name" {
  type        = string
  description = "What is the VNETs name"
}
variable "vnet_address_space" {
  type        = list(any)
  description = "What is the VNETs addresspace"
}

variable "vnet_subnet_name" {
  type        = string
  description = "What is the AVD subnet"
}

variable "vnet_subnet_address" {
  type        = list(any)
  description = "What is the subnet addresspace"
}

variable "vnet_nsg_name" {
  type        = string
  description = "Network security group name"
}

variable "laws_name_prefix" {
  type        = string
  description = "Enter the Loganalyics workspace name prefix"
}
variable "avd_diagnostics_name" {
  type        = string
  description = "How is the diagnosics settings in AVD called"
}

variable "avd_hostpool_name" {
  type        = string
  description = "What is de AVD hostpools name"
}
variable "avd_hostpool_friendly_name" {
  type        = string
  description = "What is de AVD hostpools friendly name"
}

variable "avd_hostpool_description" {
  type        = string
  description = "What is the AVD hostpools description"
}

variable "avd_hostpool_type" {
  type        = string
  description = "What is the AVD hostpools type"
}

variable "avd_applicationgroup_name" {
  type        = string
  description = "What is the AVD application group name"
}

variable "avd_applicationgroup_friendly_name" {
  type        = string
  description = "What is the AVD application group friendly name"
}

variable "avd_applicationgroup_description" {
  type        = string
  description = "What is the AVD application group description"
}

variable "avd_applicationgroup_type" {
  type        = string
  description = "What is the AVD application group type"
}

variable "avd_workspace_name" {
  type        = string
  description = "What is the AVD workspace name"
}
variable "avd_workspace_friendly_name" {
  type        = string
  description = "What is the AVD workspace friendly name"
}
variable "avd_workspace_description" {
  type        = string
  description = "What is the AVD description"
}

variable "avd_sessionhost_count" {
  type        = number
  description = "Number of session host to deploy at first time"
}

variable "avd_nic_count" {
  type        = number
  description = "Number of session host to deploy at first time"
}

variable "avd_sessionhost_prefix" {
  type        = string
  description = "The sessionhosts prefix"
}

variable "desktop_vm_image_publisher" {
  type        = string
  description = "Windows 10"
}
variable "desktop_vm_image_offer" {
  type        = string
  description = "Windows 10"
}
variable "desktop_vm_image_sku" {
  type        = string
  description = "Windows 10 20H2 Image SKU"
}
variable "desktop_vm_image_version" {
  type        = string
  description = "Latest Version"
}
variable "customer_prefix" {
  type        = string
  description = "Prefix Customer"
}
variable "sharename_groups" {
  type        = string
  description = "Share Name"
}
variable "sharename_fslogix" {
  type        = string
  description = "Share Name"
}