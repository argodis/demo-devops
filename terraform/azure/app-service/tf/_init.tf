#
# Data
#
data "azurerm_resource_group" "resource_group" {
  name = "Argodis-Henkel-Automated-Lab"
}

data "azurerm_client_config" "client_config" {
}

#
# Variables
#
variable "location" {
  type    = string
  default = "westeurope"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "prefix" {
  type    = string
  default = "0xffea"
}

variable "owner" {
  type    = string
  default = "0xffea"
}

#
# Settings
#
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.86.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
