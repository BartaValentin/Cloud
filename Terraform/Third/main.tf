terraform {
  backend "azurerm" {
    resource_group_name   = "Akademia1"
    storage_account_name  = "czm09terraformtest"
    container_name        = "tfstate"
    key                   = "bartav.tfstate"
  }
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

data "azurerm_resource_group" "this" {
  name = "Akademia1"
}

resource "azurerm_storage_table" "this" {
  name                 = "myexampletable"
  storage_account_name = azurerm_storage_account.this.name
}

resource "azurerm_storage_account" "this" {
  name                     = "valentinbartastorage01"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = data.azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table_entity" "this" {

  count = length(var.words)

  storage_account_name = azurerm_storage_account.this.name
  table_name           = azurerm_storage_table.this.name

  partition_key = length(var.words[count.index])
  row_key       = count.index + 1

  entity = {
    text   = templatefile("${path.module}/lorem_ipsum.txt", {text = var.words[count.index]})
  }
}