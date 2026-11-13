
resource "azapi_resource" "rg" {
  type      = "Microsoft.Resources/resourceGroups@2025-04-01"
  name      = "rg-${var.app_name}-${var.env_name}"
  location  = var.primary_location
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
}

data "azapi_client_config" "current" {}

resource "azapi_resource" "vm_pip" {
  type      = "Microsoft.Network/publicIPAddresses@2022-07-01"
  parent_id = azapi_resource.rg.id
  name      = "pip-${var.app_name}-${var.env_name}"
  location  = azapi_resource.rg.location
  body = {
    properties = {
      publicIPAddressVersion   = "IPv4"
      publicIPAllocationMethod = "Static"
    }
    sku = {
      name = "Standard"
    }
  }
}
