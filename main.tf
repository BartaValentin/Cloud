terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}


provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

module "childmodule" {
  source = "./modules"
  textlength = var.textlength
}


data "azurerm_resource_group" "this" {
  name = "Akademia1"
}

data "azurerm_key_vault_secret" "this" {
  name         = module.childmodule.secret_name
  key_vault_id = module.childmodule.kv_id
}


resource "azurerm_storage_account" "this" {
  name                     = "valentinstorage2"
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

resource "azurerm_storage_blob" "this" {

  provisioner "local-exec" {
    command = "bash -c 'sleep 5'"
    when    = create
  }

  name                   = "secret.txt"
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Block"
  source_content         = upper(data.azurerm_key_vault_secret.this.value)
}
