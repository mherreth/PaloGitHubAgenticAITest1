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
hostname = "192.168.1.109"
password = "Janelle_2017#"
username = "admin"
}

