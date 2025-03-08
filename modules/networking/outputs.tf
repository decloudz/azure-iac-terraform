output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.subnet[index(var.subnet_names, "aks")].id
}

output "db_subnet_id" {
  description = "ID of the database subnet"
  value       = azurerm_subnet.subnet[index(var.subnet_names, "db")].id
}

output "appgw_subnet_id" {
  description = "ID of the Application Gateway subnet"
  value       = azurerm_subnet.subnet[index(var.subnet_names, "appgw")].id
}

output "bastion_subnet_id" {
  description = "ID of the Bastion subnet"
  value       = azurerm_subnet.subnet[index(var.subnet_names, "bastion")].id
}

output "subnet_ids" {
  description = "IDs of all subnets"
  value       = { for i, name in var.subnet_names : name => azurerm_subnet.subnet[i].id }
} 