
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



