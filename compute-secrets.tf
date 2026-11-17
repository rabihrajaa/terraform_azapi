
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
