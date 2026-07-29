# Application Insights
resource "azurerm_application_insights" "this" {
  name                = var.application_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = var.log_analytics_workspace_id
  application_type    = "web"

  tags = var.tags
}

# Function App
resource "azurerm_linux_function_app" "this" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id

  storage_account_name          = var.storage_account_name
  storage_uses_managed_identity = true

  https_only                    = true
  public_network_access_enabled = true
  builtin_logging_enabled       = false

  identity {
    type = "SystemAssigned"
  }

  site_config {
    container_registry_use_managed_identity = var.use_container_image

    application_stack {
      dynamic "docker" {
        for_each = var.use_container_image ? [1] : []

        content {
          registry_url = var.docker_registry_url
          image_name   = var.docker_image_name
          image_tag    = var.docker_image_tag
        }
      }

      python_version = var.use_container_image ? null : var.python_version
    }

    scm_ip_restriction_default_action = "Allow"
    scm_use_main_ip_restriction       = !var.init_flag
    vnet_route_all_enabled            = var.init_flag ? false : var.vnet_route_all_enabled
  }

  app_settings = merge(
    {
      AzureWebJobsStorage__accountName      = var.storage_account_name
      AzureWebJobsStorage__blobServiceUri   = "https://${var.storage_account_name}.blob.core.windows.net/"
      AzureWebJobsStorage__queueServiceUri  = "https://${var.storage_account_name}.queue.core.windows.net/"
      AzureWebJobsStorage__tableServiceUri  = "https://${var.storage_account_name}.table.core.windows.net/"
      AzureWebJobsStorage__credential       = "managedidentity"
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.this.connection_string
      FUNCTIONS_WORKER_RUNTIME              = "python"
    },
    {
      for setting in var.additional_app_settings :
      setting.key => setting.value
    }
  )

  virtual_network_subnet_id = (
    var.init_flag
    ? null
    : var.virtual_network_subnet_id
  )

  tags = merge(
    var.tags,
    {
      "hidden-link: /app-insights-resource-id" = azurerm_application_insights.this.id
    }
  )
}

# 診断設定
resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = var.diagnostic_setting_name
  target_resource_id         = azurerm_linux_function_app.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}