terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

module "test007example" {
    source = "./modules/secret"
}

provider "azurerm" {
  features {}
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

  provisioner "local-exec" {
    when    = create
    command = "echo Secret created"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo Deleting secret"
  }

}

resource "azurerm_storage_container" "this" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "secret_files" {
  name                   = "secret.txt"
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Block"
  source_content         = "Teszt"
}
