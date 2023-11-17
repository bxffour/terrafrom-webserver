# Set the Azure Provider source and version being used
terraform {
  required_version = ">= 0.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }
  }
}

# Configure the Microsoft Azure provider
provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length = 8
  special = false
  upper = false
}

resource "azurerm_resource_group" "main" {
  name = "${local.cleansed_prefix}-resourcegrp"
  location = var.location
}
