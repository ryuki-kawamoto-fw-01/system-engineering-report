# =============================================================================
# Azure Function Module - Variables
# =============================================================================

# -----------------------------------------------------------------------------
# 基本設定
# -----------------------------------------------------------------------------

variable "resource_group_name" {
  description = "Azure Functionを配置するResource Group名"
  type        = string
}

variable "location" {
  description = "Azure Functionのデプロイ先リージョン"
  type        = string
}

variable "function_app_name" {
  description = "Function App名"
  type        = string
}

variable "function_app_plan_name" {
  description = "Function App Plan名。既存Planをservice_plan_idで指定する場合は未指定"
  type        = string
  default     = null
}

variable "service_plan_id" {
  description = "Function Appで使用する既存App Service PlanのリソースID"
  type        = string
  default     = null
}

variable "os_type" {
  description = "Function AppのOS種別"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "os_typeにはLinuxまたはWindowsを指定してください。"
  }
}

variable "sku_name" {
  description = "Function App Planをモジュール内で作成する場合のSKU"
  type        = string
  default     = "EP1"
}

variable "zone_balancing_enabled" {
  description = "Function App Planのゾーンバランシングを有効にするか"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Storage Account
# -----------------------------------------------------------------------------

variable "storage_account_name" {
  description = "Function Appが使用するStorage Account名"
  type        = string
}

variable "storage_account_id" {
  description = "Function Appが使用するStorage AccountのリソースID"
  type        = string
  default     = null
}

variable "storage_account_access_key" {
  description = "Storage Accountのアクセスキー。Managed Identityを使用する場合は未指定"
  type        = string
  default     = null
  sensitive   = true
}

variable "storage_uses_managed_identity" {
  description = "Function AppからStorage Accountへ接続する際にManaged Identityを使用するか"
  type        = bool
  default     = true
}

variable "use_storageaccount_queue" {
  description = "Function AppでStorage Queueを使用するか"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Application Insights
# -----------------------------------------------------------------------------

variable "application_insights_name" {
  description = "Function App用Application Insights名"
  type        = string
  default     = null
}

variable "application_insights_connection_string" {
  description = "既存Application Insightsの接続文字列"
  type        = string
  default     = null
  sensitive   = true
}

variable "application_insights_key" {
  description = "既存Application InsightsのInstrumentation Key"
  type        = string
  default     = null
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Runtime
# -----------------------------------------------------------------------------

variable "python_version" {
  description = "Pythonバージョン。コンテナーイメージ使用時はnullを指定可能"
  type        = string
  default     = "3.12"
  nullable    = true
}

variable "always_on" {
  description = "Function Appを常時稼働させるか"
  type        = bool
  default     = false
}

variable "use_32_bit_worker" {
  description = "32ビットワーカープロセスを使用するか"
  type        = bool
  default     = false
}

variable "remote_debugging_enabled" {
  description = "リモートデバッグを有効にするか"
  type        = bool
  default     = false
}

variable "builtin_logging_enabled" {
  description = "Function Appの組み込みログを有効にするか"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# TLS・認証・公開アクセス
# -----------------------------------------------------------------------------

variable "https_only" {
  description = "HTTPS通信のみを許可するか"
  type        = bool
  default     = true
}

variable "minimum_tls_version" {
  description = "Function Appで使用する最小TLSバージョン"
  type        = string
  default     = "1.2"
}

variable "ftps_state" {
  description = "FTP,FTPSの利用状態"
  type        = string
  default     = "FtpsOnly"

  validation {
    condition = contains(
      ["AllAllowed", "FtpsOnly", "Disabled"],
      var.ftps_state
    )
    error_message = "ftps_stateにはAllAllowed、FtpsOnly、Disabledのいずれかを指定してください。"
  }
}

variable "basic_auth_enabled" {
  description = "SCMおよびFTPの基本認証を有効にするか"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Function Appへのパブリックネットワークアクセスを有効にするか"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# VNet統合・ルーティング
# -----------------------------------------------------------------------------

variable "virtual_network_subnet_id" {
  description = "Function AppのVNet統合に使用するSubnet ID"
  type        = string
  default     = null
}

# 旧実装との互換性を保つため残す。
# 新しいCore側ではvirtual_network_subnet_idを使用する。
variable "vnet_integration_subnet_id" {
  description = "VNet統合用Subnet ID。旧実装との互換性維持用"
  type        = string
  default     = null
}

variable "vnet_route_all_enabled" {
  description = "Function Appのアウトバウンド通信をすべてVNet経由にするか"
  type        = bool
  default     = false
}

variable "enable_detailed_vnet_routing" {
  description = "コンテナー取得やコンテンツ共有などの詳細なVNetルーティングを有効にするか"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Managed Identity
# -----------------------------------------------------------------------------

variable "enable_system_assigned_identity" {
  description = "Function AppのSystem Assigned Managed Identityを有効にするか"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Phase制御
# -----------------------------------------------------------------------------

variable "init_flag" {
  description = "初期構築フェーズかどうか。trueはPhase 1、falseはPhase 3を表す"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# App Settings
# -----------------------------------------------------------------------------

variable "app_settings" {
  description = "Function Appへ設定する基本App Settings"
  type        = map(string)
  default     = {}
}

variable "additional_app_settings" {
  description = "テンプレートファイルなどから生成する追加App Settings"
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Cosmos DB RBAC
# -----------------------------------------------------------------------------

variable "cosmos_db_id" {
  description = "RBAC割り当て対象となるCosmos DB AccountのリソースID"
  type        = string
  default     = null
}

variable "create_cosmos_db_role_assignment" {
  description = "Function AppのManaged IdentityへCosmos DBロールを割り当てるか"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# コンテナーイメージ
# -----------------------------------------------------------------------------

variable "use_container_image" {
  description = "Function AppでDockerコンテナーイメージを使用するか"
  type        = bool
  default     = false
}

variable "docker_registry_url" {
  description = "Function Appが使用するDocker RegistryのURL"
  type        = string
  default     = null
}

variable "docker_image_name" {
  description = "Function Appが使用するDockerイメージ名"
  type        = string
  default     = null
}

variable "container_registry_id" {
  description = "Function Appが参照するAzure Container RegistryのリソースID"
  type        = string
  default     = null
}

variable "create_acr_role_assignment" {
  description = "Function AppのManaged IdentityへAcrPullロールを割り当てるか"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Diagnostic Settings
# -----------------------------------------------------------------------------

variable "enable_diagnostic_settings" {
  description = "Function Appの診断設定を作成するか"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "診断ログの送信先Log Analytics Workspace ID"
  type        = string
  default     = null
}

variable "diagnostic_setting_name" {
  description = "Function Appの診断設定名"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------

variable "tags" {
  description = "Function App関連リソースへ設定するタグ"
  type        = map(string)
  default     = {}
}

variable "docker_image_tag" {
  description = "Function Appで使用するDockerイメージのタグ"
  type        = string
  default     = "v1"
}
