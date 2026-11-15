
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

data "azapi_resource" "rg_network_dev" {
  name      = "rg-network-dev"
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Resources/resourceGroups@2025-04-01"
}

data "azapi_resource" "vnet_network_dev" {
  name      = "vnet-network-dev"
  parent_id = data.azapi_resource.rg_network_dev.id
  type      = "Microsoft.Network/virtualNetworks@2025-09-01"
}

data "azapi_resource" "snet_bravo" {
  name      = "snet-bravo"
  parent_id = data.azapi_resource.vnet_network_dev.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2022-07-01"
}

resource "azapi_resource" "networkInterface" {
  type      = "Microsoft.Network/networkInterfaces@2022-07-01"
  parent_id = azapi_resource.rg.id
  name      = "nic-${var.app_name}-${var.env_name}"
  location  = azapi_resource.rg.location
  body = {
    properties = {
      ipConfigurations = [
        {
          name = "nic-${var.app_name}-${var.env_name}"
          properties = {
            primary                   = true
            privateIPAddressVersion   = "IPv4"
            privateIPAllocationMethod = "Dynamic"
            subnet = {
              id = data.azapi_resource.snet_bravo.id
            }
            publicIPAddress = {
              id = azapi_resource.vm_pip.id
            }
          }
        },
      ]
    }
  }
}

resource "tls_private_key" "vm_ssh_pair_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}




