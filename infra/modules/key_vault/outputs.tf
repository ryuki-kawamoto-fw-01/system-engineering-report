# =============================================================================
# Key Vault Module - Outputs
# =============================================================================

output "key_vault_id" {
  description = "Key VaultのリソースID"
  value       = azurerm_key_vault.this.id
}

output "key_vault_name" {
  description = "Key Vault名"
  value       = azurerm_key_vault.this.name
}

output "key_vault_uri" {
  description = "Key VaultのURI"
  value       = azurerm_key_vault.this.vault_uri
}
