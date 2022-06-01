# In this file all variable values are stored.
# Initial Image settings
init_vm_name = "vm-init"
init_rg_name = "rg_temp-init"

# Ressource Groups
# Azure Virtual Desktop settings
avd_rg_location = "West Europe"
inf_rg_name = "rg_infrastructure"
avd_rg_name = "rg_avd"

# Virtual Network settings
vnet_name = "vnet_infrastructure"
vnet_address_space = ["10.0.0.0/16"]
vnet_subnet_name = "sn_avd"
vnet_subnet_address = ["10.0.1.0/24"]
vnet_nsg_name = "nyze-nsg-vnet-infrastructure"

# Diagnosics settings
laws_name_prefix = "laws-avd"
avd_diagnostics_name = "AVD-Diagnostics"

# VM Image 
desktop_vm_image_publisher = "MicrosoftWindowsDesktop"
desktop_vm_image_offer = "Windows-11"
desktop_vm_image_sku = "win11-21h2-avd"
desktop_vm_image_version = "latest"

## Hostpool
avd_hostpool_name = "hp_pooled01"
avd_hostpool_friendly_name = "HostPool AVD"
avd_hostpool_description = "HostPool AVD"
avd_hostpool_type = "Pooled"

## Application Group
avd_applicationgroup_name = "Nyze-Desktop"
avd_applicationgroup_friendly_name = "Applications"
avd_applicationgroup_description = "A nice group of applications"
avd_applicationgroup_type = "Desktop"

## Workpace
avd_workspace_name = "Nyze-Workspace"
avd_workspace_friendly_name = "Workspace"
avd_workspace_description = "Workspace"

## Assign to group
aad_group_name = "gr_AVD-Users"

## Sessionhosts AzureAD
avd_sessionhost_count = 1
avd_sessionhost_prefix = "avd"

## Customer Prefix 
customer_prefix = "nyze"
sharename_groups = "groups"
sharename_fslogix = "profiles"
