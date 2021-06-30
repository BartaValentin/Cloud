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
  name                      = "valentinsa"
  resource_group_name       = data.azurerm_resource_group.this.name
  location                  = data.azurerm_resource_group.this.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"

  lifecycle {
    ignore_changes = [tags]
  }

}

resource "azurerm_app_service_plan" "this" {
  name                = "azure-functions-test-service-plan"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "this" {
  name                       = "test-azure-functions-valentin"
  location                   = data.azurerm_resource_group.this.location
  resource_group_name        = data.azurerm_resource_group.this.name
  app_service_plan_id        = azurerm_app_service_plan.this.id
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  version                    = "~3"
  https_only                 = true

  app_settings = {
    FUNCTION_WORKER_RUNTIME = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "12.18.0"
    FUNCTION_APP_EDIT_MODE = "readonly"
    https_only = true
    WEBSITE_RUN_PACKAGE        = "https://valentinsa.blob.core.windows.net/valentincontainer/${azurerm_storage_blob.artifact.name}${data.azurerm_storage_account_sas.sas.sas}"
    STORAGE_ACCOUNT_CONN_STRING = azurerm_storage_account.this.primary_connection_string
    KISKUTYA = "vau"
  }

}

resource "azurerm_storage_blob" "artifact" {
  name                   = basename(var.functions_zipfile)
  storage_account_name   = "valentinsa"
  storage_container_name = "valentincontainer"
  type                   = "Block"
  source                 = var.functions_zipfile
  depends_on = [
    azurerm_storage_container.container
  ]
}

resource "azurerm_storage_container" "container" {
  name                  = "valentincontainer"
  storage_account_name  = "valentinsa"
  container_access_type = "private"
  depends_on = [
    azurerm_storage_account.this
  ]
}

data "azurerm_storage_account_sas" "sas" {
  connection_string = azurerm_storage_account.this.primary_connection_string
  https_only        = true

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = true
    table = false
    file  = false
  }

  start  = "2020-05-21"
  expiry = "2100-01-01"

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
  }
}
