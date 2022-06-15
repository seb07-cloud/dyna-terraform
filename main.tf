#Configure the Azure provider
terraform {
  cloud {
    organization = "seb07"

    workspaces {
      name = "dynabcs"
    }
  }


  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.10.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.22.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.7.2"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "time_rotating" "avd_token" {
  rotation_days = 27
}

resource "random_integer" "random" {
  min = 1
  max = 50000
}

resource "random_string" "string" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

# Create ressource groups
resource "azurerm_resource_group" "rg_avd" {
  name     = var.avd_rg_name
  location = var.avd_rg_location
}

