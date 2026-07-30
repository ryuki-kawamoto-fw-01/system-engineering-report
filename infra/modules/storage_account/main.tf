# =============================================================================
# Storage Account Module - Main Resources
# =============================================================================
# 以下のリソースを作成する。
#
# - Storage Account
# - Blob Lifecycle Management Policy（任意）
# - Blob Container
# - Storage Queue
# - 仮想フォルダー用プレースホルダーBlob
# - Blob Service診断設定
# - Queue Service診断設定
#
# Phase 1（init_flag=true）:
#   - Storage Account本体を作成する
#   - Container、Queue、フォルダー構造を作成する
#   - 初期構築に必要なネットワークアクセスを維持する
#   - Blob／Queue診断設定を作成する
#
# Phase 3（init_flag=false）:
#   - ネットワークの既定動作をDenyへ変更する
#   - 指定されたSubnetからのアクセスを許可する
#   - Blob／Queue診断設定を維持する
# =============================================================================

# =============================================================================
# Storage Account
# =============================================================================

resource "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # ---------------------------------------------------------------------------
  # Account Configuration
  # ---------------------------------------------------------------------------

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind

  # ---------------------------------------------------------------------------
  # Transport Security
  # ---------------------------------------------------------------------------

  min_tls_version            = var.min_tls_version
  https_traffic_only_enabled = var.https_traffic_only_enabled

  # BlobおよびContainerの匿名公開を禁止する。
  allow_nested_items_to_be_public = var.allow_blob_public_access

  # ---------------------------------------------------------------------------
  # Network Access
  # ---------------------------------------------------------------------------
  # public_network_access_enabled:
  #   Storage AccountのPublic Endpoint自体を利用可能にするかを制御する。
  #
  # network_default_action:
  #   Network Ruleに一致しない通信を許可するか拒否するかを制御する。
  #
  # Phase 1:
  #   public_network_access_enabled = true
  #   network_default_action        = Allow
  #   network_subnet_ids            = []
  #
  # Phase 3:
  #   public_network_access_enabled = true
  #   network_default_action        = Deny
  #   network_subnet_ids            = [Subnet 02]

  public_network_access_enabled = var.public_network_access_enabled

  network_rules {
    default_action             = var.network_default_action
    bypass                     = var.network_bypass
    ip_rules                   = var.network_ip_rules
    virtual_network_subnet_ids = var.network_subnet_ids
  }

  # ---------------------------------------------------------------------------
  # Blob Service
  # ---------------------------------------------------------------------------

  blob_properties {
    # 削除されたBlobを指定日数保持する。
    delete_retention_policy {
      days = var.blob_delete_retention_days
    }

    # 削除されたContainerを指定日数保持する。
    container_delete_retention_policy {
      days = var.blob_container_delete_retention_days
    }

    versioning_enabled  = var.blob_versioning_enabled
    change_feed_enabled = var.blob_change_feed_enabled
  }

  tags = var.tags
}

# =============================================================================
# Blob Lifecycle Management
# =============================================================================
# enable_lifecycle_management=trueの場合のみ作成する。
#
# 指定日数以上更新されていないBlock Blobを自動削除する。
# Core側で値を渡さない場合は、variables.tfのdefault=falseにより作成されない。

resource "azurerm_storage_management_policy" "this" {
  count = var.enable_lifecycle_management ? 1 : 0

  storage_account_id = azurerm_storage_account.this.id

  rule {
    name    = "deleteOldBlobs"
    enabled = true

    filters {
      blob_types = [
        "blockBlob",
      ]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = (
          var.lifecycle_delete_after_days
        )
      }
    }
  }
}

# =============================================================================
# Blob Containers
# =============================================================================
# containersに指定されたContainerを作成する。
#
# 入力例:
#
# containers = [
#   {
#     name                  = "documents"
#     container_access_type = "private"
#   }
# ]

resource "azurerm_storage_container" "this" {
  for_each = {
    for container in var.containers :
    container.name => container
  }

  name                  = each.value.name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = each.value.container_access_type
}

# =============================================================================
# Storage Queues
# =============================================================================
# queuesに指定された名前ごとにStorage Queueを作成する。

resource "azurerm_storage_queue" "this" {
  for_each = toset(var.queues)

  name               = each.value
  storage_account_id = azurerm_storage_account.this.id
}

# =============================================================================
# Folder Placeholders
# =============================================================================
# Azure Blob Storageには物理的なフォルダーが存在しないため、
# 各フォルダーパス配下へ空の.keep Blobを配置して構造を表現する。

resource "azurerm_storage_blob" "folder_placeholder" {
  for_each = {
    for placeholder in var.folder_placeholders :
    "${placeholder.container_name}/${placeholder.folder_path}" => placeholder
  }

  name = "${each.value.folder_path}/.keep"

  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = each.value.container_name

  type           = "Block"
  source_content = ""

  depends_on = [
    azurerm_storage_container.this,
  ]
}

# =============================================================================
# Diagnostic Settings - Blob Service
# =============================================================================
# Phaseに関係なく作成し、ログ・メトリックの転送を有効化する。

resource "azurerm_monitor_diagnostic_setting" "blob" {
  name = var.blob_diagnostic_setting_name

  target_resource_id = (
    "${azurerm_storage_account.this.id}/blobServices/default"
  )

  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Blob Serviceで利用可能なログカテゴリをまとめて有効化する。
  enabled_log {
    category_group = "allLogs"
  }

  # Blob Serviceのトランザクションメトリックを送信する。
  enabled_metric {
    category = "Transaction"
  }
}

# =============================================================================
# Diagnostic Settings - Queue Service
# =============================================================================
# Phaseに関係なく作成し、ログ・メトリックの転送を有効化する。

resource "azurerm_monitor_diagnostic_setting" "queue" {
  name = var.queue_diagnostic_setting_name

  target_resource_id = (
    "${azurerm_storage_account.this.id}/queueServices/default"
  )

  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Queue Serviceで利用可能なログカテゴリをまとめて有効化する。
  enabled_log {
    category_group = "allLogs"
  }

  # Queue Serviceのトランザクションメトリックを送信する。
  enabled_metric {
    category = "Transaction"
  }
}