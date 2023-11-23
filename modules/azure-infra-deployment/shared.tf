# Set the Azure Provider source and version being used
terraform {
  required_version = ">= 0.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

# Configure the Microsoft Azure provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name = "${local.cleansed_prefix}-resourcegrp"
  location = var.location
}
