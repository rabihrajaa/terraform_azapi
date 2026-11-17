
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
