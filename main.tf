
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

resource "tls_private_key" "ssh_pair_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "azapi_resource" "rg_devops_dev" {
  name      = "rg-devops-dev"
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Resources/resourceGroups@2025-04-01"
}


data "azapi_resource" "vault" {
  name      = "kv-devops-dev-souir3"
  parent_id = data.azapi_resource.rg_devops_dev.id
  type      = "Microsoft.KeyVault/vaults@2021-10-01"
}

resource "azapi_resource" "ssh_key_private_vm" {
  type                      = "Microsoft.KeyVault/vaults/secrets@2026-03-01-preview"
  parent_id                 = data.azapi_resource.vault.id
  name                      = "ssh-private-key-vm"
  schema_validation_enabled = false
  lifecycle {
    ignore_changes = [location]
  }
  body = {
    properties = {
      value = tls_private_key.ssh_pair_key.private_key_pem
    }
  }
}

resource "azapi_resource" "ssh_key_public_vm" {
  type                      = "Microsoft.KeyVault/vaults/secrets@2026-03-01-preview"
  parent_id                 = data.azapi_resource.vault.id
  name                      = "ssh-public-key-vm"
  schema_validation_enabled = false
  lifecycle {
    ignore_changes = [location]
  }
  body = {
    properties = {
      value = tls_private_key.ssh_pair_key.public_key_openssh
    }
  }
}

resource "azapi_resource" "vm" {
  type      = "Microsoft.Compute/virtualMachines@2023-03-01"
  parent_id = azapi_resource.rg.id
  name      = "vm-${var.app_name}-${var.env_name}"
  location  = azapi_resource.rg.location
  body = {
    properties = {
      hardwareProfile = {
        vmSize = "Standard_F1ads_v7"
      }
      networkProfile = {
        networkInterfaces = [
          {
            id = azapi_resource.networkInterface.id
          },
        ]
      }
      osProfile = {
        adminUsername = "adminUser"
        computerName  = "vm-${var.app_name}-${var.env_name}"
        linuxConfiguration = {
          disablePasswordAuthentication = true
          ssh = {
            publicKeys = [
              {
                path    = "/home/adminUser/.ssh/authorized_keys"
                keyData = tls_private_key.ssh_pair_key.public_key_openssh
              }
            ]
          }
        }
      }
      storageProfile = {
        imageReference = {
          offer     = "0001-com-ubuntu-server-jammy"
          publisher = "Canonical"
          sku       = "22_04-lts-gen2"
          version   = "latest"
        }
        osDisk = {
          caching      = "ReadWrite"
          createOption = "FromImage"
        }
      }
    }
  }
}









