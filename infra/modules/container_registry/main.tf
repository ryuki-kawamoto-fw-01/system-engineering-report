resource "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  public_network_access_enabled = var.init_flag ? true : var.public_network_access_enabled
  data_endpoint_enabled         = var.data_endpoint_enabled
  anonymous_pull_enabled        = var.anonymous_pull_enabled

  identity {
    type = "SystemAssigned"
  }

  network_rule_set {
    default_action = var.network_default_action

    # 信頼された Microsoft サービスによるアクセスを制御
    # init_flag = true (初回): 許可
    # init_flag = false (2回目以降): 拒否
    ip_rule = []
  }

  network_rule_bypass_option = var.init_flag ? "AzureServices" : "None"

  tags = var.tags

}

# 診断設定
resource "azurerm_monitor_diagnostic_setting" "acr_diagnostics" {
  name                       = var.diagnostic_setting_name
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}