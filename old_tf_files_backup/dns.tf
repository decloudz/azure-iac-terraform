# Create a resource group for DNS if it doesn't exist
resource "azurerm_resource_group" "dns" {
  name     = var.dns_resource_group_name
  location = var.location # Using your default location variable

  tags = {
    Environment = var.environment
    Customer    = var.customer
    ManagedBy   = "Terraform"
  }
}

# Create a new DNS Zone for the external DNS and cert-manager
resource "azurerm_dns_zone" "main" {
  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.dns.name
  
  tags = {
    Environment = var.environment
    Customer    = var.customer
    ManagedBy   = "Terraform"
  }
}

# DNS A Record for AKS ingress
resource "azurerm_dns_a_record" "aks_ingress" {
  name                = "*.aks"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.dns.name
  ttl                 = 300
  records             = [var.aks_ingress_ip]

  depends_on = [azurerm_kubernetes_cluster.aks]

  tags = {
    Environment = var.environment
    Customer    = var.customer
    ManagedBy   = "Terraform"
  }
}

# DNS A Record for the main application
resource "azurerm_dns_a_record" "app" {
  name                = "app"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.dns.name
  ttl                 = 300
  records             = [var.aks_ingress_ip]

  depends_on = [azurerm_kubernetes_cluster.aks]

  tags = {
    Environment = var.environment
    Customer    = var.customer
    ManagedBy   = "Terraform"
  }
}

# DNS A Record for the API
resource "azurerm_dns_a_record" "api" {
  name                = "api"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.dns.name
  ttl                 = 300
  records             = [var.aks_ingress_ip]

  depends_on = [azurerm_kubernetes_cluster.aks]

  tags = {
    Environment = var.environment
    Customer    = var.customer
    ManagedBy   = "Terraform"
  }
}

# DNS CNAME Record for external services
resource "azurerm_dns_cname_record" "external_service" {
  name                = "service"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.dns.name
  ttl                 = 300
  record              = "${var.kubernetes_cluster_name}.${var.dns_zone_name}"

  tags = {
    Environment = var.environment
    Customer    = var.customer
    ManagedBy   = "Terraform"
  }
} 