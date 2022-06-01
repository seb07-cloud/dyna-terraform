#Configure the Azure provider
terraform {

  cloud {
    organization = "seb07"

    workspaces {
      name = "avd"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.7.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.22.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.7.2"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "time_rotating" "avd_token" {
  rotation_days = 27
}

resource "random_integer" "random" {
  min = 1
  max = 50000
}

resource "random_string" "string" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

# Create ressource groups
resource "azurerm_resource_group" "rg_avd" {
  name     = var.avd_rg_name
  location = var.avd_rg_location
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet_infrastructure" {
  name                = "vnet_infrastructure"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg_avd.location
  resource_group_name = azurerm_resource_group.rg_avd.name
}

# Create the associated subnet
resource "azurerm_subnet" "sn_avd" {
  name                 = "sn_avd"
  resource_group_name  = azurerm_resource_group.rg_avd.name
  virtual_network_name = azurerm_virtual_network.vnet_infrastructure.name
  address_prefixes     = var.vnet_subnet_address
}

# Storage Account Groups 
resource "azurerm_storage_account" "sa_files" {
  name                     = "${var.customer_prefix}sagroups"
  resource_group_name      = azurerm_resource_group.rg_avd.name
  location                 = azurerm_resource_group.rg_avd.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  tags = {
    environment = "prod"
  }
}

# Create Azure File Share
resource "azurerm_storage_share" "groups" {
  name                 = var.sharename_groups
  storage_account_name = azurerm_storage_account.sa_files.name
  quota                = 50
}

# Storage Account FsLogix
resource "azurerm_storage_account" "sa_fslogix" {
  name                     = "${var.customer_prefix}safslogix"
  resource_group_name      = azurerm_resource_group.rg_avd.name
  location                 = azurerm_resource_group.rg_avd.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  tags = {
    environment = "prod"
  }
}

# Create Azure File Share
resource "azurerm_storage_share" "fslogix" {
  name                 = var.sharename_fslogix
  storage_account_name = azurerm_storage_account.sa_fslogix.name
  quota                = 50
}

## NSG Config
resource "azurerm_network_security_group" "nsg" {
  name                = var.vnet_nsg_name
  location            = azurerm_resource_group.rg_avd.location
  resource_group_name = azurerm_resource_group.rg_avd.name
  security_rule {
    name                       = "allow-rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 3389
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create NSG Assoc
resource "azurerm_subnet_network_security_group_association" "nsg_association-inf" {
  subnet_id                 = azurerm_subnet.sn_avd.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#AVD Config
resource "azurerm_virtual_desktop_host_pool" "avd_hp" {
  location            = azurerm_resource_group.rg_avd.location
  resource_group_name = azurerm_resource_group.rg_avd.name

  name                     = "${var.customer_prefix}_${var.avd_hostpool_name}"
  friendly_name            = var.avd_hostpool_friendly_name
  validate_environment     = false
  start_vm_on_connect      = true
  custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;targetisaadjoined:i:1;"
  description              = var.avd_hostpool_description
  type                     = var.avd_hostpool_type
  maximum_sessions_allowed = 5
  load_balancer_type       = "DepthFirst"
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.avd_hp.id
  expiration_date = time_rotating.avd_token.rotation_rfc3339
}

resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = var.avd_workspace_name
  location            = azurerm_resource_group.rg_avd.location
  resource_group_name = azurerm_resource_group.rg_avd.name
  friendly_name       = var.avd_workspace_friendly_name
  description         = var.avd_workspace_description
}

resource "azurerm_virtual_desktop_application_group" "desktopapp" {
  name                = var.avd_applicationgroup_name
  location            = azurerm_resource_group.rg_avd.location
  resource_group_name = azurerm_resource_group.rg_avd.name
  type                = var.avd_applicationgroup_type
  host_pool_id        = azurerm_virtual_desktop_host_pool.avd_hp.id
  friendly_name       = var.avd_applicationgroup_friendly_name
  description         = var.avd_applicationgroup_description
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "workspaceremoteapp" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.desktopapp.id
}

#resource "azurerm_log_analytics_workspace" "laws" {
#  name                = "${var.customer_prefix}-${var.laws_name_prefix}"
#  location            = azurerm_resource_group.rg_avd.location
#  resource_group_name = azurerm_resource_group.rg_avd.name
#  sku                 = "PerGB2018"
#  retention_in_days   = 30
#}

#resource "azurerm_monitor_diagnostic_setting" "avd-hostpool" {
#    depends_on = [
#    azurerm_virtual_desktop_host_pool.avd_hp
#  ]
#
#  name                       = "${var.customer_prefix}-avd-diagnostics"
#  target_resource_id         = azurerm_virtual_desktop_host_pool.avd_hp.id
#  log_analytics_workspace_id = azurerm_log_analytics_workspace.laws.id
#
#  log {
#    category = "Error"
#    enabled  = true
#
#    retention_policy {
#      enabled = false
#    } 
#  }
#}

resource "azurerm_public_ip" "sessionhost_ext_nic" {

  count = var.avd_sessionhost_count
  count_nic = var.avd_nic_count

  name                = "${var.customer_prefix}-${var.avd_sessionhost_prefix}-${count.index}-pip-0"
  resource_group_name = azurerm_resource_group.rg_avd.name
  location            = azurerm_resource_group.rg_avd.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "sessionhost_nic" {
  depends_on = [
    azurerm_public_ip.sessionhost_ext_nic
  ]
  count = var.avd_sessionhost_count

  name                = "${var.customer_prefix}-${var.avd_sessionhost_prefix}-${count.index}-nic-0"
  location            = azurerm_resource_group.rg_avd.location
  resource_group_name = azurerm_resource_group.rg_avd.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.sn_avd.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sessionhost_ext_nic.*.id[count.index]

  }
}

resource "azurerm_windows_virtual_machine" "avd_sessionhost" {
  depends_on = [
    azurerm_network_interface.sessionhost_nic
  ]

  count = var.avd_sessionhost_count

  name                     = "${var.customer_prefix}-${var.avd_sessionhost_prefix}-${count.index}"
  resource_group_name      = azurerm_resource_group.rg_avd.name
  location                 = azurerm_resource_group.rg_avd.location
  size                     = "Standard_D4s_v4"
  admin_username           = "adminuser"
  admin_password           = random_string.string.result
  enable_automatic_updates = true
  secure_boot_enabled      = true
  timezone                 = "W. Europe Standard Time"

  network_interface_ids = [
    "${azurerm_resource_group.rg_avd.id}/providers/Microsoft.Network/networkInterfaces/${var.customer_prefix}-${var.avd_sessionhost_prefix}-${count.index}-nic-0"
  ]

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "${var.customer_prefix}-${var.avd_sessionhost_prefix}-${count.index}-disk0"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "127"
  }

  source_image_reference {
    publisher = var.desktop_vm_image_publisher
    offer     = var.desktop_vm_image_offer
    sku       = var.desktop_vm_image_sku
    version   = var.desktop_vm_image_version
  }

  tags = {
    environment = "Production"
    hostpool    = var.avd_workspace_name
  }
}

resource "azurerm_virtual_machine_extension" "AADLoginForWindows" {
  count = var.avd_sessionhost_count
  depends_on = [
    azurerm_windows_virtual_machine.avd_sessionhost
  ]

  name                       = "AADLoginForWindows"
  virtual_machine_id         = "${azurerm_resource_group.rg_avd.id}/providers/Microsoft.Compute/virtualMachines/${var.customer_prefix}-${var.avd_sessionhost_prefix}-${count.index}"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
      "mdmId": "0000000a-0000-0000-c000-000000000000"
    }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "AVDModule" {
  count = var.avd_sessionhost_count
  depends_on = [
    azurerm_windows_virtual_machine.avd_sessionhost,
    azurerm_virtual_machine_extension.AADLoginForWindows
  ]

  name                 = "Microsoft.PowerShell.DSC"
  virtual_machine_id   = "${azurerm_resource_group.rg_avd.id}/providers/Microsoft.Compute/virtualMachines/${var.customer_prefix}-${var.avd_sessionhost_prefix}-${count.index}"
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.73"
  settings             = <<SETTINGS
    {
        "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_6-1-2021.zip",
        "ConfigurationFunction": "Configuration.ps1\\AddSessionHost",
        "Properties" : {
          "hostPoolName" : "${azurerm_virtual_desktop_host_pool.avd_hp.name}",
          "aadJoin": true
        }
    }
SETTINGS
  protected_settings   = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token}"
    }
  }
PROTECTED_SETTINGS
}

data "azuread_group" "aad_group" {
  display_name     = var.aad_group_name
  security_enabled = true
}

data "azurerm_role_definition" "vm_user_login" {
  name = "Virtual Machine User Login"
}

resource "azurerm_role_assignment" "vm_user_role" {
  scope              = azurerm_resource_group.rg_avd.id
  role_definition_id = data.azurerm_role_definition.vm_user_login.id
  principal_id       = data.azuread_group.aad_group.id
}

data "azurerm_role_definition" "desktop_user" {
  name = "Desktop Virtualization User"
}

resource "azurerm_role_assignment" "desktop_role" {
  scope              = azurerm_virtual_desktop_application_group.desktopapp.id
  role_definition_id = data.azurerm_role_definition.desktop_user.id
  principal_id       = data.azuread_group.aad_group.id
}

# Output VM Password

output "vm_password" {
  value       = random_string.string.result
  description = "VM Password"
  sensitive   = false
}
