terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>2.13.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.4.2"
    }
  }
}

provider "azapi" {

}
