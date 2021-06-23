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
  name = "Akademia1"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                       = "valentinkeyvault"
  location                   = data.azurerm_resource_group.this.location
  resource_group_name        = data.azurerm_resource_group.this.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  soft_delete_enabled        = true
  purge_protection_enabled   = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create",
      "get",
      "list"
    ]

    secret_permissions = [
      "set",
      "get",
      "list",
      "delete",
      "purge",
      "recover"
    ]

    storage_permissions = [
      "get"
    ]

  }
}

resource "random_string" "myRandomString" {
  length           = var.textlength
  special          = true
  override_special = "/@£$"
}

resource "azurerm_key_vault_secret" "this" {
  name         = "secret-by-valentin"
  value        = random_string.myRandomString.result
  key_vault_id = azurerm_key_vault.this.id
}
