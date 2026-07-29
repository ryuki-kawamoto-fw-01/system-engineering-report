output "resource_group_name" {
  description = "作成されたリソースグループの名前"
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "作成されたリソースグループのID"
  value       = azurerm_resource_group.this.id
}

output "location" {
  description = "リソースグループのロケーション"
  value       = azurerm_resource_group.this.location
}
