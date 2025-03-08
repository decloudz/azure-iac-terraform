# Networking module - main.tf
# This module manages all network resources including VNets, Subnets, NSGs, etc.

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.common_tags
}

# Create subnets
resource "azurerm_subnet" "subnet" {
  count                = length(var.subnet_names)
  name                 = "snet-${var.subnet_names[count.index]}-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefixes[count.index]]

  # For AKS subnet - enable required service endpoints
  service_endpoints = var.subnet_names[count.index] == "aks" ? [
    "Microsoft.Sql",
    "Microsoft.AzureCosmosDB",
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ] : []

  # AKS requires specific delegation
  dynamic "delegation" {
    for_each = var.subnet_names[count.index] == "appgw" ? [1] : []
    content {
      name = "appgw-delegation"
      service_delegation {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}

# Network Security Group for AKS
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "nsg-aks-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags

  # Allow HTTP traffic
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTPS traffic
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow SSH traffic
  security_rule {
    name                       = "AllowSSH"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Security Group for DB
resource "azurerm_network_security_group" "db_nsg" {
  name                = "nsg-db-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags

  # Only allow PostgreSQL traffic from AKS subnet
  security_rule {
    name                       = "AllowPostgreSQLFromAKS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = var.subnet_prefixes[index(var.subnet_names, "aks")]
    destination_address_prefix = var.subnet_prefixes[index(var.subnet_names, "db")]
  }
}

# Associate NSG with AKS subnet
resource "azurerm_subnet_network_security_group_association" "aks_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet[index(var.subnet_names, "aks")].id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

# Associate NSG with DB subnet
resource "azurerm_subnet_network_security_group_association" "db_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet[index(var.subnet_names, "db")].id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
} 