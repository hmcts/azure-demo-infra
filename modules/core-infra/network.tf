resource "azurerm_virtual_network" "core_infra" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space]

  tags = var.tags
}

output "vnet_name" {
  value = azurerm_virtual_network.core_infra.name
}

output "vnet_rg" {
  value = azurerm_virtual_network.core_infra.resource_group_name
}

resource "azurerm_network_security_group" "default" {
  location            = var.location
  name                = "default-nsg"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_network_security_group" "bastion" {
  location            = var.location
  name                = "bastion-nsg"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_network_security_rule" "PF-SSH" {
  name                        = "PF"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "213.121.161.124/32"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.bastion.name
  resource_group_name         = azurerm_network_security_group.bastion.resource_group_name
}

resource "azurerm_network_security_rule" "tls" {
  name                        = "https"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.default.name
  resource_group_name         = azurerm_network_security_group.default.resource_group_name
}

resource "azurerm_subnet" "palo-mgmt" {
  name                 = "palo-mgmt"
  resource_group_name  = azurerm_virtual_network.core_infra.resource_group_name
  virtual_network_name = azurerm_virtual_network.core_infra.name
  address_prefix       = var.palo_mgmt_address_prefix
  service_endpoints    = ["Microsoft.Storage"]

  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_subnet_network_security_group_association" "palo-mgmt" {
  network_security_group_id = azurerm_network_security_group.default.id
  subnet_id                 = azurerm_subnet.palo-mgmt.id
}

resource "azurerm_subnet" "palo-trusted" {
  name                 = "palo-trusted"
  resource_group_name  = azurerm_virtual_network.core_infra.resource_group_name
  virtual_network_name = azurerm_virtual_network.core_infra.name
  address_prefix       = var.palo_trusted_address_prefix
  service_endpoints    = ["Microsoft.Storage"]

  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_subnet_network_security_group_association" "palo-trusted" {
  network_security_group_id = azurerm_network_security_group.default.id
  subnet_id                 = azurerm_subnet.palo-trusted.id
}

resource "azurerm_subnet" "palo-untrusted" {
  name                 = "palo-untrusted"
  resource_group_name  = azurerm_virtual_network.core_infra.resource_group_name
  virtual_network_name = azurerm_virtual_network.core_infra.name
  address_prefix       = var.palo_untrusted_address_prefix
  service_endpoints    = ["Microsoft.Storage"]

  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_subnet_network_security_group_association" "palo-untrusted" {
  network_security_group_id = azurerm_network_security_group.default.id
  subnet_id                 = azurerm_subnet.palo-untrusted.id
}

resource "azurerm_subnet" "appgw" {
  name                 = "appgw"
  resource_group_name  = azurerm_virtual_network.core_infra.resource_group_name
  virtual_network_name = azurerm_virtual_network.core_infra.name
  address_prefix       = var.appgw_address_prefix

  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_subnet_network_security_group_association" "appgw" {
  network_security_group_id = azurerm_network_security_group.default.id
  subnet_id                 = azurerm_subnet.appgw.id
}

resource "azurerm_subnet" "api-mgmt" {
  name                 = "api-mgmt"
  resource_group_name  = azurerm_virtual_network.core_infra.resource_group_name
  virtual_network_name = azurerm_virtual_network.core_infra.name
  address_prefix       = var.api_mgmt_address_prefix
}

resource "azurerm_subnet" "bastion" {
  name                 = "bastion"
  resource_group_name  = azurerm_virtual_network.core_infra.resource_group_name
  virtual_network_name = azurerm_virtual_network.core_infra.name
  address_prefix       = var.bastion_address_prefix

  network_security_group_id = azurerm_network_security_group.bastion.id
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  network_security_group_id = azurerm_network_security_group.bastion.id
  subnet_id                 = azurerm_subnet.bastion.id
}
