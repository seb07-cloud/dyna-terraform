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
