# =============================================================================
# Event Grid Module - Main Resources
# =============================================================================

# Event Grid System Topicはinit_flagに関係なく作成・維持する。
# Phase 1（init_flag=true）で初回作成し、
# Phase 3（init_flag=false）では既存リソースを維持する。
resource "azurerm_eventgrid_system_topic" "system_topic" {
  name                = var.system_topic_name
  resource_group_name = var.resource_group_name
  location            = var.location
  source_resource_id  = var.storage_account_id
  topic_type          = "Microsoft.Storage.StorageAccounts"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

#以下はphase3 （init_flag=false）のときに作成するリソース
# Event Subscription for PDF conversion
resource "azurerm_eventgrid_system_topic_event_subscription" "converttopdf" {
  count               = var.enable_pdf_subscription ? 1 : 0
  name                = var.pdf_subscription_name
  system_topic        = azurerm_eventgrid_system_topic.system_topic.name
  resource_group_name = var.resource_group_name

  azure_function_endpoint {
    function_id                       = var.pdf_function_id
    max_events_per_batch              = 1
    preferred_batch_size_in_kilobytes = 64
  }

  subject_filter {
    subject_begins_with = var.pdf_container_path
  }

  included_event_types = var.included_event_types

  retry_policy {
    max_delivery_attempts = 10
    event_time_to_live    = 30
  }

  advanced_filtering_on_arrays_enabled = true

  depends_on = [azurerm_eventgrid_system_topic.system_topic]
}

# Event Subscription for Markdown conversion
resource "azurerm_eventgrid_system_topic_event_subscription" "markdown" {
  count               = var.enable_markdown_subscription ? 1 : 0
  name                = var.markdown_subscription_name
  system_topic        = azurerm_eventgrid_system_topic.system_topic.name
  resource_group_name = var.resource_group_name

  azure_function_endpoint {
    function_id                       = var.markdown_function_id
    max_events_per_batch              = 1
    preferred_batch_size_in_kilobytes = 64
  }

  subject_filter {
    subject_begins_with = var.markdown_container_path
  }

  included_event_types = var.included_event_types

  retry_policy {
    max_delivery_attempts = 10
    event_time_to_live    = 30
  }

  advanced_filtering_on_arrays_enabled = true

  depends_on = [azurerm_eventgrid_system_topic.system_topic]
}

# Event Subscription for Page Splitter
resource "azurerm_eventgrid_system_topic_event_subscription" "pagesplitter" {
  count               = var.enable_pagesplitter_subscription ? 1 : 0
  name                = var.pagesplitter_subscription_name
  system_topic        = azurerm_eventgrid_system_topic.system_topic.name
  resource_group_name = var.resource_group_name

  azure_function_endpoint {
    function_id                       = var.pagesplitter_function_id
    max_events_per_batch              = 1
    preferred_batch_size_in_kilobytes = 64
  }

  subject_filter {
    subject_begins_with = var.pagesplitter_container_path
  }

  included_event_types = var.included_event_types

  retry_policy {
    max_delivery_attempts = 10
    event_time_to_live    = 30
  }

  advanced_filtering_on_arrays_enabled = true

  depends_on = [azurerm_eventgrid_system_topic.system_topic]
}

# 診断設定
resource "azurerm_monitor_diagnostic_setting" "eventgrid_diagnostics" {
  name                       = var.diagnostic_setting_name
  target_resource_id         = azurerm_eventgrid_system_topic.system_topic.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}
