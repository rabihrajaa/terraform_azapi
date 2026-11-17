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
