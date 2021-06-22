terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

locals {
  file_content = join("\n", random_integer.this[*].result)
}

data "azurerm_resource_group" "this" {
  name = "Akademia1"
}

resource "azurerm_storage_account" "this" {
  name                     = "valentinbartastorage01"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = data.azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "this" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "random_numbers" {
  name                   = "${timestamp()}.txt"
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Block"
  source_content         = local.file_content
}

resource "random_integer" "this" {
  count = var.num_lines
  min = 1
  max = 100
}

