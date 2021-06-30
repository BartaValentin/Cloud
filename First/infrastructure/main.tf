terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "this" {
  name = "Akademia2"
}

resource "azurerm_storage_account" "this" {
  name                     = "valentinsa"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = data.azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "this" {
  name                = "azure-functions-test-service-plan"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  kind                = "FunctionApp"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "this" {
  name                       = "test-azure-functions-valentin"
  location                   = data.azurerm_resource_group.this.location
  resource_group_name        = data.azurerm_resource_group.this.name
  app_service_plan_id        = azurerm_app_service_plan.this.id
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
}
