# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = lower("${var.rg_prefix}-${var.rg_name}-${local.environment}")
  location = var.location
  tags = merge(local.default_tags,
    {
      "CreatedBy" = "aadegboye"
  })
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}