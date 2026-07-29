# =============================================================================
# Key Vault Module - Main Resources
# =============================================================================

# -----------------------------------------------------------------------------
# Key Vault
# -----------------------------------------------------------------------------
# Key Vault本体はPhase 1で作成する。
#
# Phase 1（init_flag=true）:
#   - 初期構築やアプリ配置を行えるよう、ネットワークの既定動作をAllowとする
#   - Functionコードが未配置のため、Function Host Key由来のSecretは作成しない
#
# Phase 3（init_flag=false）:
#   - ネットワークの既定動作をDenyへ変更する
#   - allowed_subnet_idsに指定したSubnetからのアクセスを許可する
#   - Function Host Key由来のSecretを作成する
#
# Phase 4:
#   - Terraform処理完了後、GitHub Actionsから
#     Public Network Accessを完全に無効化する
resource "azurerm_key_vault" "this" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = var.sku_name

  # ---------------------------------------------------------------------------
  # ネットワークアクセス制御
  # ---------------------------------------------------------------------------

  # Key Vaultのパブリックエンドポイントを利用可能にする。
  # 完全な無効化は、Terraform実行完了後のPhase 4で行う。
  public_network_access_enabled = var.public_network_access_enabled

  # Phase 1では構築用にAllowとする。
  # Phase 3ではDenyへ変更し、指定されたSubnetのみ許可する。
  network_acls {
    # Azureの信頼済みサービスからのアクセスを許可する
    bypass = "AzureServices"

    # Phaseに応じてネットワークの既定動作を切り替える
    default_action = var.init_flag ? "Allow" : "Deny"

    # Phase 1ではSubnet制限を設定しない。
    # Phase 3ではnetwork_acls_virtual_network_subnet_idsに指定されたSubnetを許可する。
    virtual_network_subnet_ids = (
      var.init_flag
      ? []
      : var.network_acls_virtual_network_subnet_ids
    )
  }

  # ---------------------------------------------------------------------------
  # アクセス制御モデル
  # ---------------------------------------------------------------------------

  # trueの場合はAzure RBACを使用する。
  # falseの場合は後続のazurerm_key_vault_access_policyを使用する。
  rbac_authorization_enabled = var.rbac_authorization_enabled

  # ---------------------------------------------------------------------------
  # Azureサービスからの利用設定
  # ---------------------------------------------------------------------------

  # Azure Virtual Machinesからの証明書取得を許可するか
  enabled_for_deployment = var.enabled_for_deployment

  # Azure Disk EncryptionからのKey Vault利用を許可するか
  enabled_for_disk_encryption = var.enabled_for_disk_encryption

  # ARM Template実行時のSecret参照を許可するか
  enabled_for_template_deployment = var.enabled_for_template_deployment

  # ---------------------------------------------------------------------------
  # 削除・復旧設定
  # ---------------------------------------------------------------------------

  # 削除されたKey Vaultデータの保持日数
  soft_delete_retention_days = var.soft_delete_retention_days

  # Soft Deleteされたデータの完全削除を防止するか
  purge_protection_enabled = var.purge_protection_enabled

  tags = var.tags

  lifecycle {
    # 現状はTerraformによる削除を許可する
    prevent_destroy = false
  }
}

# -----------------------------------------------------------------------------
# Key Vault Access Policies
# -----------------------------------------------------------------------------
# Azure RBACを使用しない場合のみ、指定されたアクセスポリシーを作成する。
#
# rbac_authorization_enabled=true:
#   count=0となり、アクセスポリシーは作成しない。
#
# rbac_authorization_enabled=false:
#   access_policiesに指定された件数分のポリシーを作成する。
resource "azurerm_key_vault_access_policy" "this" {
  count = var.rbac_authorization_enabled ? 0 : length(var.access_policies)

  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.access_policies[count.index].tenant_id
  object_id    = var.access_policies[count.index].object_id

  key_permissions         = var.access_policies[count.index].key_permissions
  secret_permissions      = var.access_policies[count.index].secret_permissions
  certificate_permissions = var.access_policies[count.index].certificate_permissions
}

# =============================================================================
# Key Vault Secrets
# =============================================================================

# Secret名だけをfor_eachの識別子として使用し、
# Secret値は機密情報のままKey Vaultへ登録する。
#
# var.secrets全体はsensitiveであるため、Mapを直接for_eachへ渡さず、
# 公開されても問題のないSecret名だけをインスタンスキーとして使用する。
#
# 注意:
# Secret値はTerraform Stateへ保存されるため、
# Stateへのアクセス権を適切に制限する。
resource "azurerm_key_vault_secret" "secrets" {
  for_each = nonsensitive(toset(keys(var.secrets)))

  # each.keyにはSecret名のみが入る
  name = each.key

  # Secret値は元のsensitiveなMapから取得する
  value = var.secrets[each.key]

  key_vault_id = azurerm_key_vault.this.id

  tags = var.tags

  depends_on = [
    azurerm_key_vault.this,
    azurerm_key_vault_access_policy.this
  ]
}

# =============================================================================
# Diagnostic Settings
# =============================================================================

# 診断設定が有効な場合のみ、Key Vaultの監査ログとメトリックを
# Log Analytics Workspaceへ送信する。
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostic_setting ? 1 : 0

  # 診断設定名が未指定の場合はKey Vault名から自動生成する
  name = (
    var.diagnostic_setting_name != null
    ? var.diagnostic_setting_name
    : "diag-${var.key_vault_name}"
  )

  # このモジュールで作成したKey Vaultを診断対象とする
  target_resource_id = azurerm_key_vault.this.id

  # 診断ログの送信先
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Key Vaultで利用可能なすべてのログを有効化する
  enabled_log {
    category_group = "allLogs"
  }

  # Key Vaultで利用可能なすべてのメトリックを有効化する
  enabled_metric {
    category = "AllMetrics"
  }
}