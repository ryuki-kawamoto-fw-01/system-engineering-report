# =============================================================================
# Cosmos DB Module - Main Resources
# =============================================================================

# -----------------------------------------------------------------------------
# Cosmos DB Account
# -----------------------------------------------------------------------------

resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = var.cosmosdb_account_name
  location            = var.location
  resource_group_name = var.resource_group_name

  offer_type = "Standard"
  kind       = "GlobalDocumentDB"

  public_network_access_enabled     = var.public_network_access_enabled
  is_virtual_network_filter_enabled = false

  automatic_failover_enabled       = var.enable_automatic_failover
  multiple_write_locations_enabled = var.enable_multiple_write_locations

  local_authentication_disabled = var.disable_local_auth
  free_tier_enabled             = var.enable_free_tier
  analytical_storage_enabled    = var.analytical_storage_enabled

  # "AzureServices"が指定された場合のみ、
  # Azureサービスからの通信をネットワークACLの対象外とする。
  network_acl_bypass_for_azure_services = (
    var.network_acl_bypass == "AzureServices"
  )

  # Cosmos DB Account全体のThroughput上限
  capacity {
    total_throughput_limit = var.total_throughput_limit
  }

  # 一貫性レベル
  consistency_policy {
    consistency_level       = var.consistency_policy.consistency_level
    max_interval_in_seconds = var.consistency_policy.max_interval_in_seconds
    max_staleness_prefix    = var.consistency_policy.max_staleness_prefix
  }

  # failover_locationsが未指定の場合は、
  # デプロイ先リージョンを優先度0のPrimary Regionとして使用する。
  dynamic "geo_location" {
    for_each = length(var.failover_locations) > 0 ? var.failover_locations : [
      {
        location          = var.location
        failover_priority = 0
        zone_redundant    = false
      }
    ]

    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = geo_location.value.zone_redundant
    }
  }

  # Backup Policy
  backup {
    type                = var.backup_policy.type
    interval_in_minutes = var.backup_policy.interval_in_minutes
    retention_in_hours  = var.backup_policy.retention_in_hours
    storage_redundancy  = var.backup_policy.storage_redundancy
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Cosmos DB SQL Databases
# -----------------------------------------------------------------------------

resource "azurerm_cosmosdb_sql_database" "database" {
  for_each = {
    for database in var.databases :
    database.name => database
  }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name

  # Autoscaleを使用する場合はManual Throughputを設定しない。
  throughput = (
    each.value.autoscale_settings == null
    ? each.value.throughput
    : null
  )

  dynamic "autoscale_settings" {
    for_each = (
      each.value.autoscale_settings != null
      ? [each.value.autoscale_settings]
      : []
    )

    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }
}

# -----------------------------------------------------------------------------
# Cosmos DB SQL Containers
# -----------------------------------------------------------------------------

resource "azurerm_cosmosdb_sql_container" "container" {
  for_each = merge([
    for database in var.databases : {
      for container in database.containers :
      "${database.name}-${container.name}" => merge(
        container,
        {
          database_name = database.name
        }
      )
    }
  ]...)

  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  database_name       = each.value.database_name

  partition_key_paths = [
    each.value.partition_key_path
  ]

  partition_key_version = 1

  depends_on = [
    azurerm_cosmosdb_sql_database.database
  ]
}

# -----------------------------------------------------------------------------
# Diagnostic Settings
# -----------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "cosmosdb_diagnostics" {
  name                       = var.diagnostic_setting_name
  target_resource_id         = azurerm_cosmosdb_account.cosmosdb.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "Requests"
  }

  enabled_metric {
    category = "SLI"
  }
}