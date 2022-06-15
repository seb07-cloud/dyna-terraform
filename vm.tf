resource "azurerm_public_ip" "sessionhost_ext_nic" {

  count = var.avd_sessionhost_count

  name                = "${var.customer_prefix}-${var.avd_sessionhost_prefix}-${count.index}-pip-0"
  resource_group_name = azurerm_resource_group.rg_avd.name
  location            = azurerm_resource_group.rg_avd.location
  allocation_method   = "Static"

  tags = {
    Environment = "STAGE"
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
    Environment = "STAGE"
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