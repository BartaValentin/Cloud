output "kv_id" {
  value = azurerm_key_vault.this.id
}

output "secret_name" {
  value = azurerm_key_vault_secret.this.name
}