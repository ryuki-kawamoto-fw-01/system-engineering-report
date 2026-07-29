# =============================================================================
# Storage Account Module - Outputs
# =============================================================================

output "id" {
  description = "Storage AccountのリソースID"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Storage Account名"
  value       = azurerm_storage_account.this.name
}

output "storage_account_name" {
  description = "Storage Account名（互換性のため）"
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "プライマリBlobエンドポイント"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_connection_string" {
  description = "プライマリ接続文字列"
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

output "primary_access_key" {
  description = "プライマリアクセスキー"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "セカンダリアクセスキー"
  value       = azurerm_storage_account.this.secondary_access_key
  sensitive   = true
}

output "primary_blob_host" {
  description = "プライマリBlobホスト"
  value       = azurerm_storage_account.this.primary_blob_host
}

output "container_ids" {
  description = "作成されたコンテナのID"
  value       = { for k, v in azurerm_storage_container.this : k => v.id }
}

output "queue_ids" {
  description = "作成されたキューのID"
  value       = { for k, v in azurerm_storage_queue.this : k => v.id }
}
