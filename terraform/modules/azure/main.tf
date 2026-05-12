# This module creates a minimal Azure presence alongside AWS.
# Useful for: cross-cloud DR, Azure AD integration, or comparing costs.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Credentials come from environment variables:
  # ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID
  # Run: az login  — then terraform will pick them up automatically
}

# Resource Group — the Azure equivalent of an AWS region namespace
resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-rg"
  location = var.azure_region
  tags     = { environment = var.environment }
}

# Virtual Network — equivalent to AWS VPC
resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  address_space       = ["10.1.0.0/16"]   # different range from AWS (10.0.0.0/16)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Subnet inside the VNet
resource "azurerm_subnet" "main" {
  name                 = "${var.project_name}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Azure Container Registry — equivalent to AWS ECR
# Store your Docker images here as a backup / for Azure deployments
resource "azurerm_container_registry" "acr" {
  name                = replace("${var.project_name}registry", "-", "")  # no hyphens allowed
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"   # cheapest tier — fine for learning
  admin_enabled       = true
}

# Storage Account — equivalent to AWS S3
resource "azurerm_storage_account" "main" {
  name                     = replace("${var.project_name}store", "-", "")
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"   # locally redundant — cheapest
}

resource "azurerm_storage_container" "assets" {
  name                  = "assets"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}