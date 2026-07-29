/**
 * Private Link Module Outputs
 * 他のモジュールから参照可能な値を公開
 */

output "private_link_service_id" {
  description = "作成されたPrivate Link ServiceのID"
  value       = azurerm_private_link_service.this.id
}

output "private_link_service_name" {
  description = "作成されたPrivate Link Serviceの名前"
  value       = azurerm_private_link_service.this.name
}

output "private_link_service_alias" {
  description = "Private Link Serviceのエイリアス（接続時に使用）"
  value       = azurerm_private_link_service.this.alias
}

output "nat_ip_configuration_ids" {
  description = "NAT IP構成のIDリスト"
  value       = [for config in azurerm_private_link_service.this.nat_ip_configuration : config.id]
}

output "nat_ip_configuration_private_ips" {
  description = "NAT IP構成のプライベートIPアドレスリスト"
  value       = [for config in azurerm_private_link_service.this.nat_ip_configuration : config.private_ip_address]
}
