# ==========================================
# Main Configuration - sst-harc/test/core
# =============================================================================
# 本ファイルでは、core環境の共通基盤を以下の順番で構築する。
#
#  1. Provider / Data Sources
#  2. Resource Group
#  3. Log Analytics Workspace
#  4. Virtual Network
#
# リソース名・アドレス空間・サブネット定義・タグなどの環境固有値は、
# 原則としてlocalsまたはenvironment.tfで一元管理する。
# =============================================================================


# =============================================================================
# 1. Provider / Data Sources
# =============================================================================

# -----------------------------------------------------------------------------
# Azure Resource Manager Provider
# -----------------------------------------------------------------------------

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  features {
    key_vault {
      # 削除済みKey Vaultを再作成する際の挙動を制御
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }

    resource_group {
      # Resource Group内にリソースが残っている場合の削除を防止
      prevent_deletion_if_contains_resources = true
    }
  }
}


# -----------------------------------------------------------------------------
# Microsoft Entra ID Provider
# -----------------------------------------------------------------------------

provider "azuread" {
  tenant_id = var.tenant_id
}


# -----------------------------------------------------------------------------
# Current Azure Context
# -----------------------------------------------------------------------------

# Terraformを実行しているID、Tenant、Subscription等の情報を取得
data "azurerm_client_config" "current" {}

# 現在のSubscription情報を取得
data "azurerm_subscription" "current" {
  subscription_id = var.subscription_id
}


# =============================================================================
# 2. Resource Group
# =============================================================================

# -----------------------------------------------------------------------------
# Common Resource Group
# -----------------------------------------------------------------------------
# core環境の各Azureリソースを格納するResource Groupを作成する。
#
# Resource Group名:
#   rg-genashi-trial-hs
#
# 配置リージョン:
#   Japan East
# -----------------------------------------------------------------------------

module "common" {
  source = "../../../../modules/common"

  resource_group_name = local.resource_group_name
  location            = local.rg_location

  tags = local.tags
}


# =============================================================================
# 3. Log Analytics Workspace
# =============================================================================

# -----------------------------------------------------------------------------
# Centralized Log Analytics Workspace
# -----------------------------------------------------------------------------
# App Service、Azure Functions、Storage Account、Cosmos DB、
# Key Vault等の診断ログを一元的に収集する。
#
# Workspace名:
#   laws-genashi-trial-hs
#
# 配置リージョン:
#   Japan West
# -----------------------------------------------------------------------------

module "log_analytics" {
  source = "../../../../modules/log_analytics"

  resource_group_name = module.common.resource_group_name
  location_name       = local.location
  log_name            = local.log_name

  tags = local.tags

  depends_on = [
    module.common
  ]
}


# =============================================================================
# 4. Virtual Network
# =============================================================================

# -----------------------------------------------------------------------------
# Core Virtual Network
# -----------------------------------------------------------------------------
# App Service / Azure FunctionsのVNet統合、およびPrivate Endpointの
# 配置先として利用するVirtual NetworkとSubnetを構築する。
#
# VNet名:
#   vnet-genashi-trial-hs
#
# Address Space:
#   environment.tfのvnet_address_spaceを参照
#
# Subnet:
#   environment.tfのsubnet_definitionsを参照
# -----------------------------------------------------------------------------

module "vnet" {
  source = "../../../../modules/vnet"

  resource_group_name = module.common.resource_group_name
  location_name       = local.rg_location

  # Virtual Network
  vnet_name     = local.vnet_name
  address_space = local.address_space

  # Subnet 01
  # Private Endpoint配置用
  subnet_01_name           = local.subnet_01_name
  subnet_01_address_prefix = local.subnet_01_address_prefix

  # Subnet 02
  # App Service / Azure Functions VNet統合用
  subnet_02_name           = local.subnet_02_name
  subnet_02_address_prefix = local.subnet_02_address_prefix

  # Subnet 03
  # 汎用リソース用
  subnet_03_name           = local.subnet_03_name
  subnet_03_address_prefix = local.subnet_03_address_prefix

  tags = local.tags

  depends_on = [
    module.common
  ]
}

# ============================================================
# 4.2 Private DNS Zone
# ============================================================
# Phase 1（init_flag=true）:
#   Private Endpointが参照するPrivate DNS Zone本体を作成する。
#   VNet Linkはまだ作成しない。
#
# Phase 3（init_flag=false）:
#   各Private DNS ZoneとVNetを接続するVNet Linkを作成し、
#   VNet内のApp ServiceやFunction Appから
#   Private Endpointの名前解決を可能にする。

# -----------------------------------------------------------------------------
# Storage Blob
# -----------------------------------------------------------------------------
module "private_dns_zone_blob" {
  source = "../../../../modules/private_dns_zone"

  dns_zone_name       = local.private_dns_zones.blob
  resource_group_name = module.common.resource_group_name

  virtual_network_ids = [
    module.vnet.vnet_id
  ]

  auto_registration_enabled = false
  init_flag                 = var.init_flag

  tags = local.tags
}

# -----------------------------------------------------------------------------
# Storage Queue
# -----------------------------------------------------------------------------
module "private_dns_zone_queue" {
  source = "../../../../modules/private_dns_zone"

  dns_zone_name       = local.private_dns_zones.queue
  resource_group_name = module.common.resource_group_name

  virtual_network_ids = [
    module.vnet.vnet_id
  ]

  auto_registration_enabled = false
  init_flag                 = var.init_flag

  tags = local.tags
}

# -----------------------------------------------------------------------------
# Azure Container Registry
# -----------------------------------------------------------------------------
module "private_dns_zone_acr" {
  source = "../../../../modules/private_dns_zone"

  dns_zone_name       = local.private_dns_zones.container_registry
  resource_group_name = module.common.resource_group_name

  virtual_network_ids = [
    module.vnet.vnet_id
  ]

  auto_registration_enabled = false
  init_flag                 = var.init_flag

  tags = local.tags
}

# -----------------------------------------------------------------------------
# Cosmos DB
# -----------------------------------------------------------------------------
module "private_dns_zone_cosmosdb" {
  source = "../../../../modules/private_dns_zone"

  dns_zone_name       = local.private_dns_zones.cosmos_db
  resource_group_name = module.common.resource_group_name

  virtual_network_ids = [
    module.vnet.vnet_id
  ]

  auto_registration_enabled = false
  init_flag                 = var.init_flag

  tags = local.tags
}

# -----------------------------------------------------------------------------
# Key Vault
# -----------------------------------------------------------------------------
module "private_dns_zone_keyvault" {
  source = "../../../../modules/private_dns_zone"

  dns_zone_name       = local.private_dns_zones.key_vault
  resource_group_name = module.common.resource_group_name

  virtual_network_ids = [
    module.vnet.vnet_id
  ]

  auto_registration_enabled = false
  init_flag                 = var.init_flag

  tags = local.tags
}

# -----------------------------------------------------------------------------
# App Service / Azure Functions
# -----------------------------------------------------------------------------
module "private_dns_zone_appservice" {
  source = "../../../../modules/private_dns_zone"

  dns_zone_name       = local.private_dns_zones.app_service
  resource_group_name = module.common.resource_group_name

  virtual_network_ids = [
    module.vnet.vnet_id
  ]

  auto_registration_enabled = false
  init_flag                 = var.init_flag

  tags = local.tags
}

# -----------------------------------------------------------------------------
# Cognitive Services
# -----------------------------------------------------------------------------
module "private_dns_zone_cognitive" {
  source = "../../../../modules/private_dns_zone"

  dns_zone_name       = local.private_dns_zones.cognitive_services
  resource_group_name = module.common.resource_group_name

  virtual_network_ids = [
    module.vnet.vnet_id
  ]

  auto_registration_enabled = false
  init_flag                 = var.init_flag

  tags = local.tags
}

# -----------------------------------------------------------------------------
# Azure OpenAI
# -----------------------------------------------------------------------------
module "private_dns_zone_openai" {
  source = "../../../../modules/private_dns_zone"

  dns_zone_name       = local.private_dns_zones.openai
  resource_group_name = module.common.resource_group_name

  virtual_network_ids = [
    module.vnet.vnet_id
  ]

  auto_registration_enabled = false
  init_flag                 = var.init_flag

  tags = local.tags
}

# -----------------------------------------------------------------------------
# Azure AI Services
# -----------------------------------------------------------------------------
module "private_dns_zone_services_ai" {
  source = "../../../../modules/private_dns_zone"

  dns_zone_name       = local.private_dns_zones.services_ai
  resource_group_name = module.common.resource_group_name

  virtual_network_ids = [
    module.vnet.vnet_id
  ]

  auto_registration_enabled = false
  init_flag                 = var.init_flag

  tags = local.tags
}

# -----------------------------------------------------------------------------
# Azure AI Search
# -----------------------------------------------------------------------------
module "private_dns_zone_search" {
  source = "../../../../modules/private_dns_zone"

  dns_zone_name       = local.private_dns_zones.search_service
  resource_group_name = module.common.resource_group_name

  virtual_network_ids = [
    module.vnet.vnet_id
  ]

  auto_registration_enabled = false
  init_flag                 = var.init_flag

  tags = local.tags
}

# =============================================================================
# 5. Storage Account
# =============================================================================
# Phase 1（init_flag=true）:
#   Storage Account本体、Container、Queue、フォルダ構造を作成する。
#   初期構築およびアプリ配置に必要なアクセス経路を維持する。
#
# Phase 3（init_flag=false）:
#   ネットワークの既定動作をDenyへ変更し、
#   Subnet 02からのアクセスのみ許可する。
module "storage_account" {
  source = "../../../../modules/storage_account"

  # 基本設定
  storage_account_name     = local.storage_account_name
  resource_group_name      = module.common.resource_group_name
  location                 = local.location
  account_tier             = local.account_tier
  account_replication_type = local.account_replication_type

  # ネットワーク制御
  # Public Endpointは維持しつつ、Phase 3で許可元をSubnet 02へ制限する。
  public_network_access_enabled = true
  network_default_action        = var.init_flag ? "Allow" : "Deny"
  network_subnet_ids = (
    var.init_flag
    ? []
    : [module.vnet.subnet_02_id]
  )

  # Blob Container
  containers = local.storage_containers

  # Storage Queue
  queues = local.storage_queues

  # 空フォルダを表現するためのプレースホルダーBlob
  folder_placeholders = local.storage_folder_placeholders

  # Blob／Queueの診断ログをLog Analyticsへ送信する。
  log_analytics_workspace_id    = module.log_analytics.log_analytics_workspace_id
  blob_diagnostic_setting_name  = local.storage_account_diagnostic_settings.blob
  queue_diagnostic_setting_name = local.storage_account_diagnostic_settings.queue

  # Phase制御
  init_flag = var.init_flag

  tags = local.tags
}

# =============================================================================
# 6. Azure Container Registry
# =============================================================================
# PDF変換Functionなどで使用するコンテナーイメージを管理する。
#
# セキュリティ方針:
#   - Premium SKUを使用する
#   - 管理者アカウントを無効化する
#   - 匿名Pullを禁止する
#   - Public Network Accessを無効化する
#   - Function AppからはManaged IdentityとAcrPull RBACで接続する
module "container_registry" {
  source = "../../../../modules/container_registry"

  # 基本設定
  container_registry_name = local.container_registry_name
  resource_group_name     = module.common.resource_group_name
  location                = local.location
  sku                     = "Premium"

  # 認証・公開設定
  admin_enabled                 = false
  anonymous_pull_enabled        = false
  public_network_access_enabled = false
  data_endpoint_enabled         = false

  # ネットワークルール
  # Public Network Access自体を無効化するため、
  # 現状はIP許可ルールを設定しない。
  network_default_action = "Allow"
  network_ip_rules       = []

  # Phase制御
  init_flag = var.init_flag

  # 診断設定
  log_analytics_workspace_id = (
    module.log_analytics.log_analytics_workspace_id
  )

  diagnostic_setting_name = (
    local.container_registry_diagnostic_setting_name
  )

  tags = local.tags
}

# =============================================================================
# 7. Cosmos DB
# =============================================================================
# Cosmos DB Account、SQL Database、SQL Containerを作成する。
#
# 各設定値はlocals.tfのlocal.cosmosdbへ集約し、
# Core側ではモジュールへの受け渡しだけを行う。
module "cosmos_db" {
  source = "../../../../modules/cosmos_db"

  # 基本設定
  resource_group_name   = module.common.resource_group_name
  location              = local.location
  cosmosdb_account_name = local.cosmosdb.account_name

  # アカウント設定
  public_network_access_enabled   = local.cosmosdb.public_network_access_enabled
  enable_automatic_failover       = local.cosmosdb.enable_automatic_failover
  enable_multiple_write_locations = local.cosmosdb.enable_multiple_write_locations
  disable_local_auth              = local.cosmosdb.disable_local_auth
  enable_free_tier                = local.cosmosdb.enable_free_tier
  analytical_storage_enabled      = local.cosmosdb.analytical_storage_enabled

  # 容量・通信設定
  capacity_mode       = local.cosmosdb.capacity_mode
  minimal_tls_version = local.cosmosdb.minimal_tls_version
  network_acl_bypass  = local.cosmosdb.network_acl_bypass

  # Cosmos DBポリシー
  consistency_policy = local.cosmosdb.consistency_policy
  backup_policy      = local.cosmosdb.backup_policy
  failover_locations = local.cosmosdb.failover_locations

  # SQL Database／Container
  databases = local.cosmosdb.databases

  # 診断設定
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.cosmosdb.diagnostic_setting_name

  tags = local.tags
}

# =============================================================================
# 8. Key Vault
# =============================================================================
# Phase 1（init_flag=true）:
#   Key Vault本体を作成し、初期構築用のアクセス状態とする。
#
# Phase 3（init_flag=false）:
#   ネットワークの既定動作をDenyへ変更し、
#   subnet_02からのアクセスのみを許可する。
#
# Function AppのHost Keyを利用するSecretは、
# Functionコード配置後のPhase 3で作成する。
module "key_vault" {
  source = "../../../../modules/key_vault"

  # ---------------------------------------------------------------------------
  # 基本設定
  # ---------------------------------------------------------------------------
  key_vault_name      = local.key_vault.name
  resource_group_name = module.common.resource_group_name
  location            = local.location
  tenant_id           = local.key_vault.tenant_id
  sku_name            = local.key_vault.sku_name

  # ---------------------------------------------------------------------------
  # アクセス制御
  # ---------------------------------------------------------------------------
  public_network_access_enabled = local.key_vault.public_network_access_enabled
  rbac_authorization_enabled    = local.key_vault.rbac_authorization_enabled

  # ---------------------------------------------------------------------------
  # Azureサービスからの利用設定
  # ---------------------------------------------------------------------------
  enabled_for_deployment          = local.key_vault.enabled_for_deployment
  enabled_for_disk_encryption     = local.key_vault.enabled_for_disk_encryption
  enabled_for_template_deployment = local.key_vault.enabled_for_template_deployment

  # ---------------------------------------------------------------------------
  # 削除・復旧設定
  # ---------------------------------------------------------------------------
  soft_delete_retention_days = local.key_vault.soft_delete_retention_days
  purge_protection_enabled   = local.key_vault.purge_protection_enabled

  # ---------------------------------------------------------------------------
  # Phase制御
  # ---------------------------------------------------------------------------
  # true:
  #   初期構築用にKey VaultのネットワークACLをAllowとする。
  #
  # false:
  #   ネットワークACLをDenyへ変更し、
  #   allowed_subnet_idsに指定されたSubnetのみ許可する。
  init_flag = var.init_flag

  # Phase 3でKey Vaultの既定アクセスをDenyへ変更した後も、
  # subnet_02からKey Vaultへアクセスできるようにする。
  #
  # Key Vaultへの接続をPrivate Endpointだけに限定する設計の場合は、
  # このSubnet許可が必要か詳細設計書と照合すること。
  network_acls_virtual_network_subnet_ids = [
    module.vnet.subnet_02_id
  ]

  # ---------------------------------------------------------------------------
  # Access Policy／Secret
  # ---------------------------------------------------------------------------
  # Azure RBACを使用するため、アクセスポリシーは作成しない。
  access_policies = []

  # Function Host Key由来のSecretはCore側で別途Phase制御するため、
  # Key Vault本体作成時には空のMapを渡す。
  secrets = {}

  # ---------------------------------------------------------------------------
  # 診断設定
  # ---------------------------------------------------------------------------
  # 診断設定はKey Vaultモジュール内部で作成する。
  enable_diagnostic_setting  = true
  diagnostic_setting_name    = local.key_vault.diagnostic_setting_name
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id

  tags = local.tags

  depends_on = [
    module.vnet,
    module.log_analytics
  ]
}

# =============================================================================
# 9. App Service
# =============================================================================
# Phase 1:
#   App Service Plan、Frontend、Load Balancer、監視リソースを作成する。
#
# Phase 3:
#   VNet統合とFrontend用RBACを有効化する。
module "app_service" {
  source = "../../../../modules/app_service"

  # 共通設定
  resource_group_name = module.common.resource_group_name
  location            = local.location

  # Frontend App Service
  frontend_app_service_name          = local.frontend_app_service_name
  frontend_app_service_runtime_stack = local.frontend_app_service_runtime_stack
  frontend_vnet_route_all_enabled    = true
  frontend_subnet_id                 = module.vnet.subnet_02_id

  # Frontend環境変数
  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/frontend-app.tpl", {
        environment_prefix       = var.environment_prefix
        security_group_object_id = var.security_group_object_id
        tenant_id                = var.tenant_id
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  # Easy Auth
  frontend_auth_client_id     = var.frontend_auth_client_id
  frontend_auth_client_secret = var.frontend_auth_client_secret
  environment_prefix          = var.environment_prefix
  tenant_id                   = var.tenant_id
  key_vault_name              = module.key_vault.key_vault_name

  # Frontend IP制限
  frontend_additional_ip_restrictions = (
    var.frontend_additional_ip_restrictions
  )

  # Load Balancer App Service
  loadbalancer_app_service_name          = local.loadbalancer_app_service_name
  loadbalancer_app_service_runtime_stack = local.loadbalancer_app_service_runtime_stack
  loadbalancer_vnet_route_all_enabled    = true
  loadbalancer_subnet_id                 = module.vnet.subnet_02_id
  loadbalancer_app_insights_resource_id  = ""

  # Load Balancer環境変数
  loadbalancer_additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/loadbalancer-app.tpl", {
        environment_prefix = var.environment_prefix
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  # App Service Plan 01
  app_service_plan_01_name     = local.app_service_plan_01_name
  app_service_plan_01_sku_name = local.app_service_plan_01_sku_name
  app_service_plan_01_os_type  = local.app_service_plan_01_os_type

  # App Service Plan 02
  app_service_plan_02_name     = local.app_service_plan_02_name
  app_service_plan_02_sku_name = local.app_service_plan_02_sku_name
  app_service_plan_02_os_type  = local.app_service_plan_02_os_type

  app_service_plan_02_maximum_elastic_worker_count = (
    local.app_service_plan_02_maximum_elastic_worker_count
  )

  # Phase 3で作成するFrontend RBAC
  frontend_key_vault_id            = module.key_vault.key_vault_id
  create_key_vault_role_assignment = !var.init_flag

  frontend_cosmos_db_id            = module.cosmos_db.cosmosdb_account_id
  create_cosmos_db_role_assignment = !var.init_flag

  # Application Insights
  frontend_application_insights_name = (
    local.app_service_application_insights.frontend
  )

  loadbalancer_application_insights_name = (
    local.app_service_application_insights.loadbalancer
  )

  # 診断設定
  log_analytics_workspace_id = (
    module.log_analytics.log_analytics_workspace_id
  )

  frontend_diagnostic_setting_name = (
    local.app_service_diagnostic_settings.frontend
  )

  loadbalancer_diagnostic_setting_name = (
    local.app_service_diagnostic_settings.loadbalancer
  )

  # Phase制御
  init_flag = var.init_flag

  tags = local.tags
}

# =============================================================================
# 10. Azure Functions
# =============================================================================
# 14個のFunction Appと、それぞれ専用のApplication Insightsを作成する。
#
# Phase 1（init_flag=true）:
#   - Function App本体を作成する
#   - Application Insightsおよび診断設定を作成する
#   - Functionコードやコンテナーの配置に必要な公開経路を維持する
#   - VNet統合はまだ有効化しない
#
# Phase 2:
#   - PythonコードまたはPDF変換用コンテナーイメージを配置する
#
# Phase 3（init_flag=false）:
#   - Function AppをSubnet 02へVNet統合する
#   - 送信通信をVNet経由へ切り替える
#   - Event Grid Subscriptionや各種RBACを別Resourceで作成する
#
# 実行基盤:
#   Plan 01（P3v3）
#     Chat、RAG、Register、PII、Prompt、MFG、
#     Agent RAG、Agent Document、Indexer
#
#   Plan 02（Premium EP1）
#     Pagesplitter 001／002、Markdown 001／002、PDF
# =============================================================================

# -----------------------------------------------------------------------------
# 01. Chat Function
# -----------------------------------------------------------------------------
# チャット要求を受け付け、Load Balancer経由で後続サービスと連携する。
module "azure_function_chat" {
  source = "../../../../modules/azure_function"

  resource_group_name = module.common.resource_group_name
  location            = local.location
  function_app_name   = local.function_app.chat.name
  service_plan_id     = module.app_service.app_service_plan_01_id

  storage_account_name          = module.storage_account.storage_account_name
  storage_account_id            = module.storage_account.id
  storage_uses_managed_identity = true
  virtual_network_subnet_id     = module.vnet.subnet_02_id

  python_version = local.function_app.chat.python_version
  init_flag      = var.init_flag

  application_insights_name  = local.function_application_insights.chat
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.function_diagnostic_settings.chat

  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/01-chat.tpl", {
        environment_prefix = var.environment_prefix
        subscription_id    = local.subscription_id
        loadbalancer_url   = "https://${module.app_service.loadbalancer_app_service_default_hostname}/"
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  tags = local.tags
}

# -----------------------------------------------------------------------------
# 02. RAG Function
# -----------------------------------------------------------------------------
# RAG処理を担当し、Load BalancerおよびCosmos DBと連携する。
# Cosmos DB RBACはPhase 3でCore側から別途作成する。
module "azure_function_rag" {
  source = "../../../../modules/azure_function"

  resource_group_name = module.common.resource_group_name
  location            = local.location
  function_app_name   = local.function_app.rag.name
  service_plan_id     = module.app_service.app_service_plan_01_id

  storage_account_name          = module.storage_account.storage_account_name
  storage_account_id            = module.storage_account.id
  storage_uses_managed_identity = true
  virtual_network_subnet_id     = module.vnet.subnet_02_id

  python_version = local.function_app.rag.python_version
  init_flag      = var.init_flag

  application_insights_name  = local.function_application_insights.rag
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.function_diagnostic_settings.rag

  cosmos_db_id                     = module.cosmos_db.cosmosdb_account_id
  create_cosmos_db_role_assignment = !var.init_flag

  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/02-rag.tpl", {
        environment_prefix = var.environment_prefix
        loadbalancer_url   = "https://${module.app_service.loadbalancer_app_service_default_hostname}/"
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  tags = local.tags
}

# -----------------------------------------------------------------------------
# 03. Register Function
# -----------------------------------------------------------------------------
# テキストおよび文書の登録処理を担当する。
module "azure_function_register" {
  source = "../../../../modules/azure_function"

  resource_group_name = module.common.resource_group_name
  location            = local.location
  function_app_name   = local.function_app.register.name
  service_plan_id     = module.app_service.app_service_plan_01_id

  storage_account_name          = module.storage_account.storage_account_name
  storage_account_id            = module.storage_account.id
  storage_uses_managed_identity = true
  virtual_network_subnet_id     = module.vnet.subnet_02_id

  python_version = local.function_app.register.python_version
  init_flag      = var.init_flag

  application_insights_name  = local.function_application_insights.register
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.function_diagnostic_settings.register

  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/03-text-register.tpl", {
        environment_prefix = var.environment_prefix
        subscription_id    = local.subscription_id
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  tags = local.tags
}

# -----------------------------------------------------------------------------
# 04. PII Function
# -----------------------------------------------------------------------------
# 個人情報に関する処理を担当する。
module "azure_function_pii" {
  source = "../../../../modules/azure_function"

  resource_group_name = module.common.resource_group_name
  location            = local.location
  function_app_name   = local.function_app.pii.name
  service_plan_id     = module.app_service.app_service_plan_01_id

  storage_account_name          = module.storage_account.storage_account_name
  storage_account_id            = module.storage_account.id
  storage_uses_managed_identity = true
  virtual_network_subnet_id     = module.vnet.subnet_02_id

  python_version = local.function_app.pii.python_version
  init_flag      = var.init_flag

  application_insights_name  = local.function_application_insights.pii
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.function_diagnostic_settings.pii

  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/04-pii.tpl", {
        environment_prefix = var.environment_prefix
        subscription_id    = local.subscription_id
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  tags = local.tags
}

# -----------------------------------------------------------------------------
# 05. Prompt Function
# -----------------------------------------------------------------------------
# プロンプト処理を担当し、Load BalancerおよびCosmos DBと連携する。
# Cosmos DB RBACはPhase 3でCore側から別途作成する。
module "azure_function_prompt" {
  source = "../../../../modules/azure_function"

  resource_group_name = module.common.resource_group_name
  location            = local.location
  function_app_name   = local.function_app.prompt.name
  service_plan_id     = module.app_service.app_service_plan_01_id

  storage_account_name          = module.storage_account.storage_account_name
  storage_account_id            = module.storage_account.id
  storage_uses_managed_identity = true
  virtual_network_subnet_id     = module.vnet.subnet_02_id

  python_version = local.function_app.prompt.python_version
  init_flag      = var.init_flag

  application_insights_name  = local.function_application_insights.prompt
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.function_diagnostic_settings.prompt

  cosmos_db_id                     = module.cosmos_db.cosmosdb_account_id
  create_cosmos_db_role_assignment = !var.init_flag

  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/05-prompt.tpl", {
        environment_prefix = var.environment_prefix
        loadbalancer_url   = "https://${module.app_service.loadbalancer_app_service_default_hostname}/"
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  tags = local.tags
}

# -----------------------------------------------------------------------------
# 06. Pagesplitter 001 Function
# -----------------------------------------------------------------------------
# 規格検索向けのページ分割処理を担当する。
# Phase 3ではEvent Grid Subscriptionの配送先となる。
module "azure_function_pagespliter_001" {
  source = "../../../../modules/azure_function"

  resource_group_name = module.common.resource_group_name
  location            = local.location
  function_app_name   = local.function_app.pagespliter_001.name
  service_plan_id     = module.app_service.app_service_plan_02_id

  storage_account_name          = module.storage_account.storage_account_name
  storage_account_id            = module.storage_account.id
  storage_uses_managed_identity = true
  virtual_network_subnet_id     = module.vnet.subnet_02_id

  python_version           = local.function_app.pagespliter_001.python_version
  init_flag                = var.init_flag
  use_storageaccount_queue = true

  application_insights_name  = local.function_application_insights.pagespliter_001
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.function_diagnostic_settings.pagespliter_001

  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/06-pagesplitter.tpl", {
        environment_prefix = var.environment_prefix
        subscription_id    = local.subscription_id
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  tags = local.tags
}

# -----------------------------------------------------------------------------
# 07. Markdown 001 Function
# -----------------------------------------------------------------------------
# 規格検索向けのMarkdown変換処理を担当する。
# Phase 3ではEvent Grid Subscriptionの配送先となる。
module "azure_function_markdown_001" {
  source = "../../../../modules/azure_function"

  resource_group_name = module.common.resource_group_name
  location            = local.location
  function_app_name   = local.function_app.markdown_001.name
  service_plan_id     = module.app_service.app_service_plan_02_id

  storage_account_name          = module.storage_account.storage_account_name
  storage_account_id            = module.storage_account.id
  storage_uses_managed_identity = true
  virtual_network_subnet_id     = module.vnet.subnet_02_id

  python_version           = local.function_app.markdown_001.python_version
  init_flag                = var.init_flag
  use_storageaccount_queue = true

  application_insights_name  = local.function_application_insights.markdown_001
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.function_diagnostic_settings.markdown_001

  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/07-markdown.tpl", {
        environment_prefix = var.environment_prefix
        subscription_id    = local.subscription_id
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  tags = local.tags
}

# -----------------------------------------------------------------------------
# 08. PDF Function
# -----------------------------------------------------------------------------
# Blobイベントを契機にPDF変換処理を実行する。
# 通常のPython Runtimeではなく、ACR上のコンテナーを使用する。
#
# AcrPull RBACおよび詳細VNet Routingは、PDF固有処理として
# Core側の独立Resourceで作成する。
module "azure_function_pdf" {
  source = "../../../../modules/azure_function"

  resource_group_name = module.common.resource_group_name
  location            = local.location
  function_app_name   = local.function_app.pdf.name
  service_plan_id     = module.app_service.app_service_plan_02_id

  storage_account_name          = module.storage_account.storage_account_name
  storage_account_id            = module.storage_account.id
  storage_uses_managed_identity = true
  virtual_network_subnet_id     = module.vnet.subnet_02_id

  init_flag                = var.init_flag
  use_storageaccount_queue = true

  use_container_image = true
  docker_registry_url = "https://${local.container_registry_name}.azurecr.io"
  docker_image_name   = "convert-to-pdf"
  python_version      = null

  vnet_route_all_enabled       = true
  enable_detailed_vnet_routing = true
  container_registry_id        = module.container_registry.container_registry_id
  create_acr_role_assignment   = true

  application_insights_name  = local.function_application_insights.pdf
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.function_diagnostic_settings.pdf

  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/08-pdf.tpl", {
        environment_prefix = var.environment_prefix
        subscription_id    = local.subscription_id
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  tags = local.tags
}

# -----------------------------------------------------------------------------
# 09. MFG Function
# -----------------------------------------------------------------------------
# 製造業向け処理を担当し、Load Balancer経由で後続サービスと連携する。
module "azure_function_mfg" {
  source = "../../../../modules/azure_function"

  resource_group_name = module.common.resource_group_name
  location            = local.location
  function_app_name   = local.function_app.mfg.name
  service_plan_id     = module.app_service.app_service_plan_01_id

  storage_account_name          = module.storage_account.storage_account_name
  storage_account_id            = module.storage_account.id
  storage_uses_managed_identity = true
  virtual_network_subnet_id     = module.vnet.subnet_02_id

  python_version = local.function_app.mfg.python_version
  init_flag      = var.init_flag

  application_insights_name  = local.function_application_insights.mfg
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.function_diagnostic_settings.mfg

  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/09-mfg.tpl", {
        environment_prefix = var.environment_prefix
        subscription_id    = local.subscription_id
        loadbalancer_url   = "https://${module.app_service.loadbalancer_app_service_default_hostname}/"
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  tags = local.tags
}

# -----------------------------------------------------------------------------
# 10. Agent RAG Function
# -----------------------------------------------------------------------------
# Agentから利用されるRAG処理を担当する。
# Cosmos DB RBACはPhase 3でCore側から別途作成する。
module "azure_function_agent_rag" {
  source = "../../../../modules/azure_function"

  resource_group_name = module.common.resource_group_name
  location            = local.location
  function_app_name   = local.function_app.agent_rag.name
  service_plan_id     = module.app_service.app_service_plan_01_id

  storage_account_name          = module.storage_account.storage_account_name
  storage_account_id            = module.storage_account.id
  storage_uses_managed_identity = true
  virtual_network_subnet_id     = module.vnet.subnet_02_id

  python_version = local.function_app.agent_rag.python_version
  init_flag      = var.init_flag

  application_insights_name  = local.function_application_insights.agent_rag
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.function_diagnostic_settings.agent_rag

  cosmos_db_id                     = module.cosmos_db.cosmosdb_account_id
  create_cosmos_db_role_assignment = !var.init_flag

  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/10-agent-rag.tpl", {
        environment_prefix = var.environment_prefix
        loadbalancer_url   = "https://${module.app_service.loadbalancer_app_service_default_hostname}/"
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  tags = local.tags
}

# -----------------------------------------------------------------------------
# 11. Agent Document Function
# -----------------------------------------------------------------------------
# Agentから利用される文書処理を担当する。
module "azure_function_agent_document" {
  source = "../../../../modules/azure_function"

  resource_group_name = module.common.resource_group_name
  location            = local.location
  function_app_name   = local.function_app.agent_document.name
  service_plan_id     = module.app_service.app_service_plan_01_id

  storage_account_name          = module.storage_account.storage_account_name
  storage_account_id            = module.storage_account.id
  storage_uses_managed_identity = true
  virtual_network_subnet_id     = module.vnet.subnet_02_id

  python_version = local.function_app.agent_document.python_version
  init_flag      = var.init_flag

  application_insights_name  = local.function_application_insights.agent_document
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.function_diagnostic_settings.agent_document

  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/11-agent-document.tpl", {
        environment_prefix = var.environment_prefix
        subscription_id    = local.subscription_id
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  tags = local.tags
}

# -----------------------------------------------------------------------------
# 12. Pagesplitter 002 Function
# -----------------------------------------------------------------------------
# 標準文書向けのページ分割処理を担当する。
module "azure_function_pagespliter_002" {
  source = "../../../../modules/azure_function"

  resource_group_name = module.common.resource_group_name
  location            = local.location
  function_app_name   = local.function_app.pagespliter_002.name
  service_plan_id     = module.app_service.app_service_plan_02_id

  storage_account_name          = module.storage_account.storage_account_name
  storage_account_id            = module.storage_account.id
  storage_uses_managed_identity = true
  virtual_network_subnet_id     = module.vnet.subnet_02_id

  python_version           = local.function_app.pagespliter_002.python_version
  init_flag                = var.init_flag
  use_storageaccount_queue = true

  application_insights_name  = local.function_application_insights.pagespliter_002
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.function_diagnostic_settings.pagespliter_002

  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/12-page-std.tpl", {
        environment_prefix = var.environment_prefix
        subscription_id    = local.subscription_id
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  tags = local.tags
}

# -----------------------------------------------------------------------------
# 13. Markdown 002 Function
# -----------------------------------------------------------------------------
# 標準文書向けのMarkdown変換処理を担当する。
module "azure_function_markdown_002" {
  source = "../../../../modules/azure_function"

  resource_group_name = module.common.resource_group_name
  location            = local.location
  function_app_name   = local.function_app.markdown_002.name
  service_plan_id     = module.app_service.app_service_plan_02_id

  storage_account_name          = module.storage_account.storage_account_name
  storage_account_id            = module.storage_account.id
  storage_uses_managed_identity = true
  virtual_network_subnet_id     = module.vnet.subnet_02_id

  python_version           = local.function_app.markdown_002.python_version
  init_flag                = var.init_flag
  use_storageaccount_queue = true

  application_insights_name  = local.function_application_insights.markdown_002
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.function_diagnostic_settings.markdown_002

  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/13-mark-std.tpl", {
        environment_prefix = var.environment_prefix
        subscription_id    = local.subscription_id
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  tags = local.tags
}

# -----------------------------------------------------------------------------
# 14. Indexer Function
# -----------------------------------------------------------------------------
# インデックス更新に関する処理を担当する。
module "azure_function_indexer" {
  source = "../../../../modules/azure_function"

  resource_group_name = module.common.resource_group_name
  location            = local.location
  function_app_name   = local.function_app.indexer.name
  service_plan_id     = module.app_service.app_service_plan_01_id

  storage_account_name          = module.storage_account.storage_account_name
  storage_account_id            = module.storage_account.id
  storage_uses_managed_identity = true
  virtual_network_subnet_id     = module.vnet.subnet_02_id

  python_version = local.function_app.indexer.python_version
  init_flag      = var.init_flag

  application_insights_name  = local.function_application_insights.indexer
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  diagnostic_setting_name    = local.function_diagnostic_settings.indexer

  additional_app_settings = [
    for setting_name, setting_value in jsondecode(
      templatefile("${path.module}/env_vars/14-indexer.tpl", {
        environment_prefix = var.environment_prefix
        subscription_id    = local.subscription_id
      })
      ) : {
      key   = setting_name
      value = setting_value
    }
  ]

  tags = local.tags
}

# =============================================================================
# 11. Dynamic Function App Credentials Management
# =============================================================================
# Functionコード配置後のPhase 3でFunction Host KeyとURLを取得し、
# Key VaultへSecretとして登録する。
#
# init_flag=true:
#   Data SourceとSecretを作成しない。
#
# init_flag=false:
#   Function情報とHost Keyを取得してSecretを作成する。
# Phase 1：init_flag=true
# → Data Source／Secretとも0件
# Phase 3：init_flag=false
# → Host Keyを取得してSecretを作成

# Chat Function App
data "azurerm_linux_function_app" "chat" {
  count               = var.init_flag ? 0 : 1
  name                = local.function_app.chat.name
  resource_group_name = module.common.resource_group_name

  depends_on = [module.azure_function_chat]
}

data "azurerm_function_app_host_keys" "chat" {
  count               = var.init_flag ? 0 : 1
  name                = local.function_app.chat.name
  resource_group_name = module.common.resource_group_name

  depends_on = [
    module.azure_function_chat
  ]
}

# RAG Function App
data "azurerm_linux_function_app" "rag" {
  count               = var.init_flag ? 0 : 1
  name                = local.function_app.rag.name
  resource_group_name = module.common.resource_group_name

  depends_on = [module.azure_function_rag]
}

data "azurerm_function_app_host_keys" "rag" {
  count               = var.init_flag ? 0 : 1
  name                = local.function_app.rag.name
  resource_group_name = module.common.resource_group_name

  depends_on = [
    module.azure_function_rag
  ]
}

# Register Function App
data "azurerm_function_app_host_keys" "register" {
  count               = var.init_flag ? 0 : 1
  name                = local.function_app.register.name
  resource_group_name = module.common.resource_group_name

  depends_on = [
    module.azure_function_register
  ]
}

# PII Function App
data "azurerm_linux_function_app" "pii" {
  count               = var.init_flag ? 0 : 1
  name                = local.function_app.pii.name
  resource_group_name = module.common.resource_group_name

  depends_on = [module.azure_function_pii]
}

data "azurerm_function_app_host_keys" "pii" {
  count               = var.init_flag ? 0 : 1
  name                = local.function_app.pii.name
  resource_group_name = module.common.resource_group_name

  depends_on = [
    module.azure_function_pii
  ]
}

# MFG Function App
data "azurerm_function_app_host_keys" "mfg" {
  count               = var.init_flag ? 0 : 1
  name                = local.function_app.mfg.name
  resource_group_name = module.common.resource_group_name

  depends_on = [
    module.azure_function_mfg
  ]
}

# Agent RAG Function App
data "azurerm_function_app_host_keys" "agent_rag" {
  count               = var.init_flag ? 0 : 1
  name                = local.function_app.agent_rag.name
  resource_group_name = module.common.resource_group_name

  depends_on = [
    module.azure_function_agent_rag
  ]
}

# Agent Document Function App
data "azurerm_linux_function_app" "agent_document" {
  count               = var.init_flag ? 0 : 1
  name                = local.function_app.agent_document.name
  resource_group_name = module.common.resource_group_name

  depends_on = [module.azure_function_agent_document]
}

data "azurerm_function_app_host_keys" "agent_document" {
  count               = var.init_flag ? 0 : 1
  name                = local.function_app.agent_document.name
  resource_group_name = module.common.resource_group_name

  depends_on = [
    module.azure_function_agent_document
  ]
}

# Prompt Function App
data "azurerm_linux_function_app" "prompt" {
  count               = var.init_flag ? 0 : 1
  name                = local.function_app.prompt.name
  resource_group_name = module.common.resource_group_name

  depends_on = [module.azure_function_prompt]
}

data "azurerm_function_app_host_keys" "prompt" {
  count               = var.init_flag ? 0 : 1
  name                = local.function_app.prompt.name
  resource_group_name = module.common.resource_group_name

  depends_on = [
    module.azure_function_prompt
  ]
}

# --- Key Vault Secrets: Function App情報をシークレットとして格納 ---

resource "azurerm_key_vault_secret" "orchestrator_agent_api_credential" {
  count        = var.init_flag ? 0 : 1
  name         = local.key_vault_secret_names.orchestrator_agent_api_credential
  value        = data.azurerm_function_app_host_keys.agent_rag[0].default_function_key
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [
    module.key_vault,
    data.azurerm_function_app_host_keys.agent_rag
  ]
}

resource "azurerm_key_vault_secret" "orchestrator_api_url" {
  count        = var.init_flag ? 0 : 1
  name         = local.key_vault_secret_names.orchestrator_api_url
  value        = "https://${data.azurerm_linux_function_app.chat[0].default_hostname}/api/chat?code=${data.azurerm_function_app_host_keys.chat[0].default_function_key}"
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [
    module.key_vault,
    data.azurerm_linux_function_app.chat,
    data.azurerm_function_app_host_keys.chat
  ]
}

resource "azurerm_key_vault_secret" "orchestrator_document_api_credential" {
  count        = var.init_flag ? 0 : 1
  name         = local.key_vault_secret_names.orchestrator_document_api_credential
  value        = data.azurerm_function_app_host_keys.register[0].default_function_key
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [
    module.key_vault,
    data.azurerm_function_app_host_keys.register
  ]
}

resource "azurerm_key_vault_secret" "orchestrator_file_api_credential" {
  count        = var.init_flag ? 0 : 1
  name         = local.key_vault_secret_names.orchestrator_file_api_credential
  value        = data.azurerm_function_app_host_keys.chat[0].default_function_key
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [
    module.key_vault,
    data.azurerm_function_app_host_keys.chat
  ]
}

resource "azurerm_key_vault_secret" "orchestrator_it_api_credential" {
  count        = var.init_flag ? 0 : 1
  name         = local.key_vault_secret_names.orchestrator_it_api_credential
  value        = data.azurerm_function_app_host_keys.mfg[0].default_function_key
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [
    module.key_vault,
    data.azurerm_function_app_host_keys.mfg
  ]
}

resource "azurerm_key_vault_secret" "orchestrator_mfg_api_credential" {
  count        = var.init_flag ? 0 : 1
  name         = local.key_vault_secret_names.orchestrator_mfg_api_credential
  value        = data.azurerm_function_app_host_keys.mfg[0].default_function_key
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [
    module.key_vault,
    data.azurerm_function_app_host_keys.mfg
  ]
}

resource "azurerm_key_vault_secret" "orchestrator_pii_api_url" {
  count        = var.init_flag ? 0 : 1
  name         = local.key_vault_secret_names.orchestrator_pii_api_url
  value        = "https://${data.azurerm_linux_function_app.pii[0].default_hostname}/api/pii?code=${data.azurerm_function_app_host_keys.pii[0].default_function_key}"
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [
    module.key_vault,
    data.azurerm_linux_function_app.pii,
    data.azurerm_function_app_host_keys.pii
  ]
}

resource "azurerm_key_vault_secret" "orchestrator_rag_api_url" {
  count        = var.init_flag ? 0 : 1
  name         = local.key_vault_secret_names.orchestrator_rag_api_url
  value        = "https://${data.azurerm_linux_function_app.rag[0].default_hostname}/api/rag-chat?code=${data.azurerm_function_app_host_keys.rag[0].default_function_key}"
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [
    module.key_vault,
    data.azurerm_linux_function_app.rag,
    data.azurerm_function_app_host_keys.rag
  ]
}

resource "azurerm_key_vault_secret" "orchestrator_standard_api_credential" {
  count        = var.init_flag ? 0 : 1
  name         = local.key_vault_secret_names.orchestrator_standard_api_credential
  value        = data.azurerm_function_app_host_keys.agent_document[0].default_function_key
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [
    module.key_vault,
    data.azurerm_function_app_host_keys.agent_document
  ]
}

resource "azurerm_key_vault_secret" "orchestrator_use_case_api_credential" {
  count        = var.init_flag ? 0 : 1
  name         = local.key_vault_secret_names.orchestrator_use_case_api_credential
  value        = data.azurerm_function_app_host_keys.prompt[0].default_function_key
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [
    module.key_vault,
    data.azurerm_function_app_host_keys.prompt
  ]
}

# ============================================================
# 12. Private Endpoints
# ============================================================

# Private Endpoint - Storage Account (Blob)
module "private_endpoint_blob" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.storage_blob
  private_connection_resource_id = module.storage_account.id
  subresource_names              = ["blob"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "blob-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_blob.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_blob]
}

# Private Endpoint - Storage Account (Queue)
module "private_endpoint_queue" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.storage_queue
  private_connection_resource_id = module.storage_account.id
  subresource_names              = ["queue"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "queue-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_queue.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_queue]
}

# Private Endpoint - Container Registry
module "private_endpoint_acr" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.container_registry
  private_connection_resource_id = module.container_registry.container_registry_id
  subresource_names              = ["registry"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "acr-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_acr.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_acr]
}

# Private Endpoint - Cosmos DB
module "private_endpoint_cosmosdb" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.cosmos_db
  private_connection_resource_id = module.cosmos_db.cosmosdb_account_id
  subresource_names              = ["Sql"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "cosmosdb-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_cosmosdb.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_cosmosdb]
}

# Private Endpoint - Key Vault
module "private_endpoint_keyvault" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.key_vault
  private_connection_resource_id = module.key_vault.key_vault_id
  subresource_names              = ["vault"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "keyvault-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_keyvault.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_keyvault]
}

# Private Endpoint - Load Balancer App Service
module "private_endpoint_lb" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.loadbalancer
  private_connection_resource_id = module.app_service.loadbalancer_app_service_id
  subresource_names              = ["sites"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "loadbalancer-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_appservice.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_appservice]
}

# Private Endpoint - Azure Function (Agent Document)
module "private_endpoint_agent_document" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.agent_document
  private_connection_resource_id = module.azure_function_agent_document.azure_function_id
  subresource_names              = ["sites"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "function-agent-doc-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_appservice.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_appservice]
}

# Private Endpoint - Azure Function (Agent RAG)
module "private_endpoint_agent_rag" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.agent_rag
  private_connection_resource_id = module.azure_function_agent_rag.azure_function_id
  subresource_names              = ["sites"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "function-agent-rag-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_appservice.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_appservice]
}

# Private Endpoint - Azure Function (Chat)
module "private_endpoint_chat" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.chat
  private_connection_resource_id = module.azure_function_chat.azure_function_id
  subresource_names              = ["sites"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "function-chat-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_appservice.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_appservice]
}

# Private Endpoint - Azure Function (Indexer)
module "private_endpoint_rag_f" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.indexer
  private_connection_resource_id = module.azure_function_indexer.azure_function_id
  subresource_names              = ["sites"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "function-indexer-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_appservice.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_appservice]
}

# Private Endpoint - Azure Function (MFG)
module "private_endpoint_mfg" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.mfg
  private_connection_resource_id = module.azure_function_mfg.azure_function_id
  subresource_names              = ["sites"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "function-mfg-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_appservice.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_appservice]
}

# Private Endpoint - Azure Function (PDF)
module "private_endpoint_pdf" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.pdf
  private_connection_resource_id = module.azure_function_pdf.azure_function_id
  subresource_names              = ["sites"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "function-pdf-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_appservice.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_appservice]
}

# Private Endpoint - Azure Function (PII)
module "private_endpoint_pii" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.pii
  private_connection_resource_id = module.azure_function_pii.azure_function_id
  subresource_names              = ["sites"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "function-pii-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_appservice.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_appservice]
}

# Private Endpoint - Azure Function (Prompt)
module "private_endpoint_prompt" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.prompt
  private_connection_resource_id = module.azure_function_prompt.azure_function_id
  subresource_names              = ["sites"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "function-prompt-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_appservice.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_appservice]
}

# Private Endpoint - Azure Function (RAG)
module "private_endpoint_rag" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.rag
  private_connection_resource_id = module.azure_function_rag.azure_function_id
  subresource_names              = ["sites"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "function-rag-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_appservice.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_appservice]
}

# Private Endpoint - Azure Function (Register)
module "private_endpoint_register" {
  source = "../../../../modules/private_endpoint"

  location                       = local.location
  resource_group_name            = module.common.resource_group_name
  subnet_id                      = module.vnet.subnet_01_id
  private_endpoint_name          = local.private_endpoint.register
  private_connection_resource_id = module.azure_function_register.azure_function_id
  subresource_names              = ["sites"]

  # Private DNS integration
  enable_private_dns_zone_group = true
  private_dns_zone_group_name   = "function-register-dns-zone-group"
  private_dns_zone_ids          = [module.private_dns_zone_appservice.private_dns_zone_id]

  tags = local.tags

  depends_on = [module.private_dns_zone_appservice]
}

# ============================================================
# 13. Event Grid
# ============================================================
# Phase 1／init_flag=true
#   → Event Grid System Topicだけ作成
#   → Event Subscriptionは作成しない

# Phase 2
#   → PDF・Markdown・PagesplitterのFunctionコードを配置
#   → Azure上に各Function名を登録

# Phase 3／init_flag=false
#   → 3つのEvent Subscriptionを作成
#   → Storageイベントと各Functionを接続

module "event_grid" {
  source = "../../../../modules/event_grid"

  resource_group_name = module.common.resource_group_name
  location            = local.location

  # System Topic
  system_topic_name  = local.event_grid.system_topic_name
  storage_account_id = module.storage_account.id

  # PDF Conversion Event Subscription
  enable_pdf_subscription = !var.init_flag
  pdf_subscription_name   = "converttopdf"
  pdf_function_id         = "${module.azure_function_pdf.azure_function_id}/functions/blob_trigger"
  pdf_container_path      = local.event_grid.pdf_container_path

  # Markdown Conversion Event Subscription
  enable_markdown_subscription = !var.init_flag
  markdown_subscription_name   = "mrkdown"
  markdown_function_id         = "${module.azure_function_markdown_001.azure_function_id}/functions/markdown"
  markdown_container_path      = local.event_grid.markdown_container_path

  # Page Splitter Event Subscription
  enable_pagesplitter_subscription = !var.init_flag
  pagesplitter_subscription_name   = "pagesplitter"
  pagesplitter_function_id         = "${module.azure_function_pagespliter_001.azure_function_id}/functions/page_splitter"
  pagesplitter_container_path      = local.event_grid.pagesplitter_container_path

  # 診断設定
  diagnostic_setting_name    = local.event_grid.diagnostic_setting_name
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id

  tags = local.tags

  # Function Appsの作成を確実に待つための依存関係
  depends_on = [
    module.azure_function_pdf,
    module.azure_function_markdown_001,
    module.azure_function_pagespliter_001
  ]
}

# ============================================================
# 14. Azure Monitor
# ============================================================
module "azure_monitor" {
  source = "../../../../modules/azure_monitor"

  # parameters
  resource_group_name = module.common.resource_group_name
  location            = local.location

  # Action Group
  action_group_name       = local.azure_monitor.action_group_name
  action_group_short_name = local.azure_monitor.action_group_short_name
  action_group_enabled    = local.azure_monitor.action_group_enabled
  email_receivers         = local.azure_monitor.email_receivers

  # Resource Health Alert
  resource_health_alert_name           = local.azure_monitor.resource_health_alert_name
  resource_health_evaluation_frequency = local.azure_monitor.resource_health_evaluation_frequency
  resource_health_window_duration      = local.azure_monitor.resource_health_window_duration
  resource_health_scopes               = [module.log_analytics.log_analytics_workspace_id]
  resource_health_severity             = local.azure_monitor.resource_health_severity
  resource_health_enabled              = local.azure_monitor.resource_health_enabled
  resource_health_auto_mitigation      = local.azure_monitor.resource_health_auto_mitigation
  resource_health_query                = local.azure_monitor.resource_health_query

  # Service Health Alert 01
  service_health_alert_01_name = local.azure_monitor.service_health_alert_01_name
  service_health_scopes        = local.azure_monitor.service_health_scopes
  service_health_01_enabled    = local.azure_monitor.service_health_01_enabled
  service_health_01_events     = ["Incident", "Maintenance", "Informational", "ActionRequired", "Security"]
  service_health_01_locations  = local.azure_monitor.service_health_01_locations
  service_health_01_services   = local.azure_monitor.service_health_01_services

  # Service Health Alert 02
  service_health_alert_02_name = local.azure_monitor.service_health_alert_02_name
  service_health_02_enabled    = local.azure_monitor.service_health_02_enabled
  service_health_02_events     = ["Incident", "Maintenance", "Informational", "ActionRequired", "Security"]
  service_health_02_locations  = local.azure_monitor.service_health_02_locations
  service_health_02_services   = local.azure_monitor.service_health_02_services

  tags = local.tags
}
