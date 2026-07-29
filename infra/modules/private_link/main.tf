/**
 * Private Link Module
 * Private Link Serviceを作成し、サービス間プライベート接続を構成する
 */

# Private Link Service
resource "azurerm_private_link_service" "this" {
  name                = var.private_link_service_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Load BalancerのフロントエンドIP構成（必須）
  load_balancer_frontend_ip_configuration_ids = var.load_balancer_frontend_ip_configuration_ids

  # NAT IP構成（1つ以上必須）
  dynamic "nat_ip_configuration" {
    for_each = var.nat_ip_configurations
    content {
      name                       = nat_ip_configuration.value.name
      subnet_id                  = nat_ip_configuration.value.subnet_id
      primary                    = nat_ip_configuration.value.primary
      private_ip_address         = nat_ip_configuration.value.private_ip_address
      private_ip_address_version = nat_ip_configuration.value.private_ip_address_version
    }
  }

  # 自動承認設定（オプション）
  auto_approval_subscription_ids = length(var.auto_approval_subscription_ids) > 0 ? var.auto_approval_subscription_ids : null

  # 可視性設定（オプション）
  visibility_subscription_ids = length(var.visibility_subscription_ids) > 0 ? var.visibility_subscription_ids : null

  # TCP Proxyプロトコル設定
  enable_proxy_protocol = var.enable_proxy_protocol

  # FQDN設定（オプション）
  fqdns = length(var.fqdns) > 0 ? var.fqdns : null

  tags = var.tags
}
