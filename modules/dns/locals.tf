locals {
  # Validate that OIDC issuer URL is provided if federated identity is enabled
  validate_oidc = (
    var.create_federated_identity && var.oidc_issuer_url == "" 
    ? tobool("Error: oidc_issuer_url must be provided when create_federated_identity is true") 
    : true
  )
} 