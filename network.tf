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