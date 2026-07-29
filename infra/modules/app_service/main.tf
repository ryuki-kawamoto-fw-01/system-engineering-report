# =============================================================================
# App Service Module - Main Resources
# =============================================================================
# 以下のリソースを作成する。
#
# - App Service Plan 01
# - App Service Plan 02
# - Frontend用Application Insights
# - Load Balancer用Application Insights
# - Frontend App Service
# - Load Balancer App Service
# - SCM／FTP基本認証ポリシー
# - Frontend Easy Auth
# - Frontend認証用Key Vault Secret
# - Frontend／Load Balancer診断設定
# - Frontend用Key Vault RBAC
# - Frontend用Cosmos DB SQL RBAC
#
# Phase 1（init_flag=true）:
#   - App Serviceと監視リソースを作成する
#   - アプリを配置できるようPublic Accessを維持する
#   - VNet統合およびRBACは作成しない
#   - Easy AuthのClient SecretはApp Settingsへ一時的に直接設定する
#
# Phase 3（init_flag=false）:
#   - Frontend／Load BalancerをVNetへ統合する
#   - FrontendのIP制限を適用する
#   - Load BalancerのPublic Accessを無効化する
#   - Frontend認証SecretをKey Vaultへ登録する
#   - App SettingsをKey Vault参照へ切り替える
#   - FrontendのManaged IdentityへKey Vault／Cosmos DB権限を付与する
# =============================================================================

# =============================================================================
# Local Values
# =============================================================================

locals {
  # ---------------------------------------------------------------------------
  # Frontend共通IP制限
  # ---------------------------------------------------------------------------
  # 全環境で共通して許可する社内ProxyおよびUmbrellaのIP範囲。
  frontend_base_ip_restrictions = [
    {
      name        = "hitachi-proxy-001"
      priority    = 1001
      action      = "Allow"
      ip_address  = "202.246.252.96/27"
      service_tag = null
    },
    {
      name        = "hitachi-proxy-002"
      priority    = 1002
      action      = "Allow"
      ip_address  = "202.246.252.128/25"
      service_tag = null
    },
    {
      name        = "hitachi-proxy-003"
      priority    = 1003
      action      = "Allow"
      ip_address  = "180.12.177.128/28"
      service_tag = null
    },
    {
      name        = "hitachi-proxy-004"
      priority    = 1004
      action      = "Allow"
      ip_address  = "202.252.109.0/24"
      service_tag = null
    },
    {
      name        = "hitachi-proxy-005"
      priority    = 1005
      action      = "Allow"
      ip_address  = "180.12.177.153/32"
      service_tag = null
    },
    {
      name        = "hitachi-proxy-006"
      priority    = 1006
      action      = "Allow"
      ip_address  = "119.81.77.52/31"
      service_tag = null
    },
    {
      name        = "hitachi-proxy-007"
      priority    = 1007
      action      = "Allow"
      ip_address  = "194.223.149.212/31"
      service_tag = null
    },
    {
      name        = "hitachi-proxy-008"
      priority    = 1008
      action      = "Allow"
      ip_address  = "148.109.35.210/31"
      service_tag = null
    },
    {
      name        = "hitachi-proxy-009"
      priority    = 1009
      action      = "Allow"
      ip_address  = "194.223.149.82/31"
      service_tag = null
    },
    {
      name        = "hitachi-proxy-010"
      priority    = 1010
      action      = "Allow"
      ip_address  = "158.213.160.0/26"
      service_tag = null
    },
    {
      name        = "hitachi-proxy-011"
      priority    = 1011
      action      = "Allow"
      ip_address  = "158.213.204.0/24"
      service_tag = null
    },
    {
      name        = "hitachi-proxy-012"
      priority    = 1012
      action      = "Allow"
      ip_address  = "158.213.151.0/24"
      service_tag = null
    },
    {
      name        = "hitachi-proxy-013"
      priority    = 1013
      action      = "Allow"
      ip_address  = "158.214.171.192/26"
      service_tag = null
    },
    {
      name        = "umbrella-001"
      priority    = 2001
      action      = "Allow"
      ip_address  = "155.190.0.0/16"
      service_tag = null
    },
    {
      name        = "umbrella-002"
      priority    = 2002
      action      = "Allow"
      ip_address  = "146.112.0.0/16"
      service_tag = null
    },
    {
      name        = "umbrella-003"
      priority    = 2003
      action      = "Allow"
      ip_address  = "151.186.144.0/20"
      service_tag = null
    },
    {
      name        = "umbrella-004"
      priority    = 2004
      action      = "Allow"
      ip_address  = "151.186.160.0/20"
      service_tag = null
    },
    {
      name        = "umbrella-005"
      priority    = 2005
      action      = "Allow"
      ip_address  = "151.186.176.0/20"
      service_tag = null
    },
    {
      name        = "umbrella-006"
      priority    = 2006
      action      = "Allow"
      ip_address  = "151.186.192.0/20"
      service_tag = null
    }
  ]

  # 共通IP制限と環境固有IP制限を統合する。
  frontend_ip_restrictions = concat(
    local.frontend_base_ip_restrictions,
    var.frontend_additional_ip_restrictions
  )

  # list(object({ key, value }))をApp Service用のmap(string)へ変換する。
  frontend_app_settings = {
    for setting in var.additional_app_settings :
    setting.key => setting.value
  }

  loadbalancer_app_settings = {
    for setting in var.loadbalancer_additional_app_settings :
    setting.key => setting.value
  }

  # Phase 1ではClient Secretを直接設定する。
  # Phase 3ではKey Vault参照へ切り替える。
  frontend_auth_secret_value = (
    var.init_flag
    ? var.frontend_auth_client_secret
    : "@Microsoft.KeyVault(VaultName=${var.key_vault_name};SecretName=MICROSOFT-PROVIDER-AUTHENTICATION-SECRET)"
  )
}

# =============================================================================
# App Service Plans
# =============================================================================

# -----------------------------------------------------------------------------
# App Service Plan 01
# -----------------------------------------------------------------------------
# Frontend、Load Balancerおよび通常のPython Functionで使用する。
resource "azurerm_service_plan" "plan_01" {
  name                = var.app_service_plan_01_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.app_service_plan_01_os_type
  sku_name            = var.app_service_plan_01_sku_name

  tags = var.tags
}

# -----------------------------------------------------------------------------
# App Service Plan 02
# -----------------------------------------------------------------------------
# PDF、Markdown、PagesplitterなどのFunctionで使用する。
resource "azurerm_service_plan" "plan_02" {
  name                = var.app_service_plan_02_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.app_service_plan_02_os_type
  sku_name            = var.app_service_plan_02_sku_name

  maximum_elastic_worker_count = (
    var.app_service_plan_02_maximum_elastic_worker_count
  )

  tags = var.tags
}

# =============================================================================
# Application Insights
# =============================================================================

# -----------------------------------------------------------------------------
# Frontend用Application Insights
# -----------------------------------------------------------------------------
resource "azurerm_application_insights" "frontend" {
  name                = var.frontend_application_insights_name
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = var.log_analytics_workspace_id
  application_type    = "web"

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Load Balancer用Application Insights
# -----------------------------------------------------------------------------
resource "azurerm_application_insights" "loadbalancer" {
  name                = var.loadbalancer_application_insights_name
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = var.log_analytics_workspace_id
  application_type    = "web"

  tags = var.tags
}

# =============================================================================
# Frontend App Service
# =============================================================================

resource "azurerm_linux_web_app" "frontend" {
  name                = var.frontend_app_service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.plan_01.id

  https_only                    = true
  public_network_access_enabled = true
  client_affinity_enabled       = false

  # SCM／FTPの基本認証は後続のAzAPI Resourceでも明示的に無効化する。
  webdeploy_publish_basic_authentication_enabled = false
  ftp_publish_basic_authentication_enabled       = false

  # Phase 1ではアプリ配置を優先してVNet統合を保留する。
  # Phase 3でSubnetへ接続する。
  virtual_network_subnet_id = (
    var.init_flag
    ? null
    : var.frontend_subnet_id
  )

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on           = true
    ftps_state          = "Disabled"
    minimum_tls_version = "1.2"
    http2_enabled       = false

    vnet_route_all_enabled = (
      var.init_flag
      ? false
      : var.frontend_vnet_route_all_enabled
    )

    # Phase 1ではデプロイのためアクセス制限を適用しない。
    # Phase 3では許可リスト以外を拒否する。
    ip_restriction_default_action = (
      var.init_flag
      ? "Allow"
      : "Deny"
    )

    dynamic "ip_restriction" {
      for_each = var.init_flag ? [] : local.frontend_ip_restrictions

      content {
        name        = ip_restriction.value.name
        priority    = ip_restriction.value.priority
        action      = ip_restriction.value.action
        ip_address  = try(ip_restriction.value.ip_address, null)
        service_tag = try(ip_restriction.value.service_tag, null)
      }
    }

    # Phase 1ではSCMを利用可能にする。
    # Phase 3ではメインサイトのIP制限をSCMへ継承する。
    scm_ip_restriction_default_action = (
      var.init_flag
      ? "Allow"
      : "Deny"
    )

    scm_use_main_ip_restriction = !var.init_flag

    application_stack {
      node_version = var.frontend_app_service_runtime_stack
    }
  }

  app_settings = merge(
    local.frontend_app_settings,
    {
      WEBSITE_RUN_FROM_PACKAGE = "1"

      APPLICATIONINSIGHTS_CONNECTION_STRING = (
        azurerm_application_insights.frontend.connection_string
      )

      MICROSOFT_PROVIDER_AUTHENTICATION_SECRET = (
        local.frontend_auth_secret_value
      )
    }
  )

  # Microsoft Entra IDによるEasy Auth。
  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    unauthenticated_action = "RedirectToLoginPage"
    default_provider       = "azureactivedirectory"

    active_directory_v2 {
      client_id                  = var.frontend_auth_client_id
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
      tenant_auth_endpoint       = "https://sts.windows.net/${var.tenant_id}/v2.0"

      allowed_audiences = [
        "api://${var.frontend_auth_client_id}"
      ]
    }

    login {
      token_store_enabled = true
    }
  }

  tags = merge(
    var.tags,
    {
      "hidden-link: /app-insights-resource-id" = (
        azurerm_application_insights.frontend.id
      )
    }
  )

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      app_settings["SCM_DO_BUILD_DURING_DEPLOYMENT"],
    ]
  }
}

# =============================================================================
# Load Balancer App Service
# =============================================================================

resource "azurerm_linux_web_app" "loadbalancer" {
  name                = var.loadbalancer_app_service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.plan_01.id

  https_only = true

  # Phase 1ではアプリ配置のためPublic Accessを有効化する。
  # Phase 3ではVNet経由のアクセスへ移行する。
  public_network_access_enabled = var.init_flag

  client_affinity_enabled = false

  webdeploy_publish_basic_authentication_enabled = false
  ftp_publish_basic_authentication_enabled       = false

  virtual_network_subnet_id = (
    var.init_flag
    ? null
    : var.loadbalancer_subnet_id
  )

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on           = true
    ftps_state          = "Disabled"
    minimum_tls_version = "1.2"
    http2_enabled       = false

    vnet_route_all_enabled = (
      var.init_flag
      ? false
      : var.loadbalancer_vnet_route_all_enabled
    )

    scm_ip_restriction_default_action = "Allow"
    scm_use_main_ip_restriction       = !var.init_flag

    application_stack {
      dotnet_version = var.loadbalancer_app_service_runtime_stack
    }

    # 解答版と同様、Load Balancerのメインサイトは許可ルールを保持する。
    ip_restriction {
      name       = "allow-all"
      priority   = 2147483647
      action     = "Allow"
      ip_address = "0.0.0.0/0"
    }
  }

  app_settings = merge(
    local.loadbalancer_app_settings,
    {
      WEBSITE_RUN_FROM_PACKAGE = "1"

      APPLICATIONINSIGHTS_CONNECTION_STRING = (
        azurerm_application_insights.loadbalancer.connection_string
      )
    }
  )

  tags = merge(
    var.tags,
    {
      "hidden-link: /app-insights-resource-id" = (
        azurerm_application_insights.loadbalancer.id
      )
    }
  )

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      app_settings["SCM_DO_BUILD_DURING_DEPLOYMENT"],
    ]
  }
}

# =============================================================================
# Basic Publishing Authentication
# =============================================================================
# AzureRM Provider側でもfalseを指定しているが、
# SCM／FTPポリシーResourceにも明示的に無効化を設定する。

resource "azapi_update_resource" "frontend_scm_basic_auth" {
  type        = "Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01"
  resource_id = "${azurerm_linux_web_app.frontend.id}/basicPublishingCredentialsPolicies/scm"

  body = {
    properties = {
      allow = false
    }
  }
}

resource "azapi_update_resource" "frontend_ftp_basic_auth" {
  type        = "Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01"
  resource_id = "${azurerm_linux_web_app.frontend.id}/basicPublishingCredentialsPolicies/ftp"

  body = {
    properties = {
      allow = false
    }
  }
}

resource "azapi_update_resource" "loadbalancer_scm_basic_auth" {
  type        = "Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01"
  resource_id = "${azurerm_linux_web_app.loadbalancer.id}/basicPublishingCredentialsPolicies/scm"

  body = {
    properties = {
      allow = false
    }
  }
}

resource "azapi_update_resource" "loadbalancer_ftp_basic_auth" {
  type        = "Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01"
  resource_id = "${azurerm_linux_web_app.loadbalancer.id}/basicPublishingCredentialsPolicies/ftp"

  body = {
    properties = {
      allow = false
    }
  }
}

# =============================================================================
# Frontend Authentication Secret
# =============================================================================
# Phase 3で認証用Client SecretをKey Vaultへ登録する。
#
# Frontendへ付与するKey Vault Secrets Userは読取権限であり、
# Terraform実行主体がSecretを登録する権限とは別である。

resource "azurerm_key_vault_secret" "frontend_auth" {
  count = var.init_flag ? 0 : 1

  name         = "MICROSOFT-PROVIDER-AUTHENTICATION-SECRET"
  value        = var.frontend_auth_client_secret
  key_vault_id = var.frontend_key_vault_id
}

# =============================================================================
# Diagnostic Settings
# =============================================================================

# -----------------------------------------------------------------------------
# Frontend診断設定
# -----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "frontend" {
  name                       = var.frontend_diagnostic_setting_name
  target_resource_id         = azurerm_linux_web_app.frontend.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# -----------------------------------------------------------------------------
# Load Balancer診断設定
# -----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "loadbalancer" {
  name                       = var.loadbalancer_diagnostic_setting_name
  target_resource_id         = azurerm_linux_web_app.loadbalancer.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# =============================================================================
# Frontend Key Vault RBAC
# =============================================================================
# Phase 3でFrontendのManaged IdentityへSecret読取権限を付与する。

resource "azurerm_role_assignment" "frontend_key_vault_secrets_user" {
  count = var.create_key_vault_role_assignment ? 1 : 0

  scope                = var.frontend_key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.frontend.identity[0].principal_id

  skip_service_principal_aad_check = true
}

# =============================================================================
# Frontend Cosmos DB RBAC
# =============================================================================
# Phase 3でFrontendのManaged Identityへ
# Cosmos DB Built-in Data Contributorを割り当てる。

resource "azurerm_cosmosdb_sql_role_assignment" "frontend" {
  count = var.create_cosmos_db_role_assignment ? 1 : 0

  resource_group_name = var.resource_group_name

  account_name = element(
    split("/", var.frontend_cosmos_db_id),
    length(split("/", var.frontend_cosmos_db_id)) - 1
  )

  role_definition_id = "${var.frontend_cosmos_db_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"

  principal_id = azurerm_linux_web_app.frontend.identity[0].principal_id
  scope        = var.frontend_cosmos_db_id
}