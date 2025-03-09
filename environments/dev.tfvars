rg_name = "symmetry"

log_analytics_workspace_rg_name     = "workspace"
log_analytics_workspace_name        = "workspace1"

# virtual network
vnet_rg_name                        = "vnet1"
vnet_location                       = "East US"
hub_vnet_name                       = "hub"
hub_vnet_address_space              = ["10.63.0.0/20"]
hub_gateway_subnet_name             = "gateway"
hub_gateway_subnet_address_prefixes = ["10.63.0.0/25"] // HostMin:   10.63.0.1 , HostMax:   10.63.0.126  
hub_bastion_subnet_name             = "AzureBastionSubnet"
hub_bastion_subnet_address_prefixes = ["10.63.0.128/28"] //HostMin:   10.63.0.129,HostMax:   10.63.0.142
appgtw_subnet_name                  = "appgtw"
appgtw_address_prefixes             = "10.63.1.0/28"
hub_firewall_subnet_name            = "AzureFirewallSubnet"
hub_firewall_subnet_address_prefixes= ["10.63.2.0/24"]
spoke_vnet_name                     = "spoke" //spoke_vnet_name
spoke_vnet_address_space            = ["10.64.0.0/16"]
aks_subnet_name                     = "aks1"
aks_address_prefixes                = "10.64.4.0/22"
psql_subnet_name                    = "psql1"
psql_address_prefixes               = "10.64.2.0/26"
jumpbox_subnet_name                 = "jumpbox"
jumpbox_subnet_address_prefix       = ["10.64.3.0/28"]




# container registry
acr_rg_name                         = "acr"
acr_name                            = "acrgcsymmetry"
acr_sku                             = "Premium"
acr_admin_enabled                   = true
data_endpoint_enabled               = false
private_endpoint_prefix             = "pe"
request_message                     = "Please approve this connection"



# application gateway
appgtw_name                         = "appgtw1"
appgtw_sku_size                     = "WAF_v2"
appgtw_sku_tier                     = "WAF_v2"
appgtw_sku_capacity                 = 2
appgtw_pip_name                     = "appgtw"
pip_allocation_method               = "Static"
pip_sku                             = "Standard"



# Azure Kubernetes Service (AKS) 
aks_rg_name                         = "aks"
aks_rg_location                     = "East US"
kubernetes_version                  = "1.30.9"
cluster_name                        = "cluster1"
dns_prefix                          = "cluster1-dns"
private_cluster_enabled             = false
aks_sku_tier                        = "Free"
default_node_pool_node_count        = 2
default_node_pool_vm_size           = "Standard_B4ms"
admin_username                      = "azadmin"
ssh_public_key                      = "ssh_pub_keys/azureuser.pub"



# PostgreSQL
psql_rg_name                        = "Postgresql"
psql_name                           = "Postgresql1"
psql_sku_name                       = "B_Standard_B1ms"
psql_admin_login                    = "postgres"
psql_admin_password                 = "Test1234t"
psql_version                        = "13"
psql_storage_mb                     = "262144"
postgresql_admin_password           = "Password123!"


# key vault
kv_name                             = "keyvault1" 
kv_sku_name                         = "standard"
kv_owner_object_id                  = "d0abdc5c-2ba6-4868-8387-d700969c7111"

# DNS configuration
dns_zone_name              = "symmetry.prime-edm.com"
dns_resource_group_name    = "rg-dns-dev"
enable_cert_manager        = true
cert_manager_namespace     = "cert-manager"
cert_manager_email         = "admin@symmetry.prime-edm.com"
cert_manager_identity_name = "cert-manager-identity"
enable_external_dns        = true
external_dns_namespace     = "external-dns"
external_dns_identity_name = "external-dns-identity"
external_dns_chart_version = "1.13.1"
kubernetes_cluster_name    = "aks-cluster1-dev"
kubernetes_cluster_exists  = true



# Module behavior
create_k8s_resources        = false
create_federated_identity   = true
create_dns_role_assignment  = false
create_wildcard_record      = false