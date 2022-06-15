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