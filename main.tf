
resource "azapi_resource" "rg" {
  type      = "Microsoft.Resources/resourceGroups@2025-04-01"
  name      = "rg-${var.app_name}-${var.env_name}"
  location  = var.primary_location
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
}

data "azapi_client_config" "current" {}









