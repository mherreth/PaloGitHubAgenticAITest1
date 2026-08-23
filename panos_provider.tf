terraform {
  required_providers {
    panos = {
      source  = "paloaltonetworks/panos"
      version = "=1.10.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.1"
    }

  }
}


provider "azurerm" {
  features {}
}

provider "panos" {
  hostname = var["panorama-server"]
  password = var.password
  username = var.username
}
