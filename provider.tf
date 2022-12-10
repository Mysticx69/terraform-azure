##############################################################
# Configure Providers
##############################################################
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "mysticx"

    workspaces {
      name = "azure-cpe"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.34.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.31.0"
    }
  }

  required_version = "~> 1.3.6"
}

provider "azurerm" {
  features {

  }
}

provider "azuread" {
}

##############################################################
# Fetched Data
##############################################################
data "azuread_domains" "default" {
  only_initial = true
}

data "azuread_client_config" "current" {}
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "primary" {}
