# =============================================================================
# App Service Module - Variables
# =============================================================================

# -----------------------------------------------------------------------------
# 共通設定
# -----------------------------------------------------------------------------

variable "resource_group_name" {
  description = "App Service関連リソースを配置するResource Group名"
  type        = string
}

variable "location" {
  description = "App Service関連リソースのデプロイ先リージョン"
  type        = string
}

variable "init_flag" {
  description = "初期構築フェーズかどうか。trueは初期構築、falseは後続設定"
  type        = bool
  default     = true
}

variable "tags" {
  description = "App Service関連リソースへ設定するタグ"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# App Service Plan 01
# -----------------------------------------------------------------------------

variable "app_service_plan_01_name" {
  description = "App Service Plan 01の名前"
  type        = string
}

variable "app_service_plan_01_sku_name" {
  description = "App Service Plan 01のSKU"
  type        = string
}

variable "app_service_plan_01_os_type" {
  description = "App Service Plan 01のOS種別"
  type        = string
  default     = "Linux"

  validation {
    condition = contains(
      ["Linux", "Windows"],
      var.app_service_plan_01_os_type
    )
    error_message = "app_service_plan_01_os_typeにはLinuxまたはWindowsを指定してください。"
  }
}

# -----------------------------------------------------------------------------
# App Service Plan 02
# -----------------------------------------------------------------------------

variable "app_service_plan_02_name" {
  description = "App Service Plan 02の名前"
  type        = string
}

variable "app_service_plan_02_sku_name" {
  description = "App Service Plan 02のSKU"
  type        = string
}

variable "app_service_plan_02_os_type" {
  description = "App Service Plan 02のOS種別"
  type        = string
  default     = "Linux"

  validation {
    condition = contains(
      ["Linux", "Windows"],
      var.app_service_plan_02_os_type
    )
    error_message = "app_service_plan_02_os_typeにはLinuxまたはWindowsを指定してください。"
  }
}

variable "app_service_plan_02_maximum_elastic_worker_count" {
  description = "App Service Plan 02の最大Elastic Worker数"
  type        = number
  default     = null
}

# -----------------------------------------------------------------------------
# Frontend App Service
# -----------------------------------------------------------------------------

variable "frontend_app_service_name" {
  description = "Frontend App Service名"
  type        = string
}

variable "frontend_app_service_runtime_stack" {
  description = "Frontend App ServiceのRuntime Stack"
  type        = string
}

variable "frontend_subnet_id" {
  description = "Frontend App ServiceのVNet統合用Subnet ID"
  type        = string
  default     = null
}

variable "frontend_vnet_route_all_enabled" {
  description = "Frontendの送信通信をすべてVNet経由にするか"
  type        = bool
  default     = true
}

variable "additional_app_settings" {
  description = "Frontend App Serviceへ追加するApp Settings"

  type = list(object({
    key   = string
    value = string
  }))

  default = []
}

# -----------------------------------------------------------------------------
# Frontend Easy Auth
# -----------------------------------------------------------------------------

variable "frontend_auth_client_id" {
  description = "Frontend Easy Authで使用するClient ID"
  type        = string
}

variable "frontend_auth_client_secret" {
  description = "Frontend Easy Authで使用するClient Secret"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Microsoft Entra ID Tenant ID"
  type        = string
}

variable "environment_prefix" {
  description = "環境識別子"
  type        = string
}

variable "key_vault_name" {
  description = "FrontendのEasy Authで参照するKey Vault名"
  type        = string
}

# -----------------------------------------------------------------------------
# Frontend IP Restrictions
# -----------------------------------------------------------------------------

variable "frontend_additional_ip_restrictions" {
  description = "Frontend App Serviceへ追加するIPアクセス制限"

  type = list(object({
    name        = string
    priority    = number
    action      = string
    ip_address  = optional(string)
    service_tag = optional(string)
  }))

  default = []

  validation {
    condition = alltrue([
      for restriction in var.frontend_additional_ip_restrictions :
      contains(["Allow", "Deny"], restriction.action)
    ])
    error_message = "IP制限のactionにはAllowまたはDenyを指定してください。"
  }
}

# -----------------------------------------------------------------------------
# Load Balancer App Service
# -----------------------------------------------------------------------------

variable "loadbalancer_app_service_name" {
  description = "Load Balancer App Service名"
  type        = string
}

variable "loadbalancer_app_service_runtime_stack" {
  description = "Load Balancer App ServiceのRuntime Stack"
  type        = string
}

variable "loadbalancer_subnet_id" {
  description = "Load Balancer App ServiceのVNet統合用Subnet ID"
  type        = string
  default     = null
}

variable "loadbalancer_vnet_route_all_enabled" {
  description = "Load Balancerの送信通信をすべてVNet経由にするか"
  type        = bool
  default     = true
}

variable "loadbalancer_additional_app_settings" {
  description = "Load Balancer App Serviceへ追加するApp Settings"

  type = list(object({
    key   = string
    value = string
  }))

  default = []
}

variable "loadbalancer_app_insights_resource_id" {
  description = "外部作成済みLoad Balancer用Application InsightsのResource ID"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Application Insights
# -----------------------------------------------------------------------------

variable "frontend_application_insights_name" {
  description = "Frontend用Application Insights名"
  type        = string
}

variable "loadbalancer_application_insights_name" {
  description = "Load Balancer用Application Insights名"
  type        = string
}

# -----------------------------------------------------------------------------
# Diagnostic Settings
# -----------------------------------------------------------------------------

variable "log_analytics_workspace_id" {
  description = "ログ送信先Log Analytics Workspace ID"
  type        = string
}

variable "frontend_diagnostic_setting_name" {
  description = "Frontend App Serviceの診断設定名"
  type        = string
}

variable "loadbalancer_diagnostic_setting_name" {
  description = "Load Balancer App Serviceの診断設定名"
  type        = string
}

# -----------------------------------------------------------------------------
# Frontend Key Vault RBAC
# -----------------------------------------------------------------------------

variable "frontend_key_vault_id" {
  description = "FrontendのManaged Identityへ権限を付与するKey Vault ID"
  type        = string
  default     = null
}

variable "create_key_vault_role_assignment" {
  description = "FrontendへKey Vaultロールを割り当てるか"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Frontend Cosmos DB RBAC
# -----------------------------------------------------------------------------

variable "frontend_cosmos_db_id" {
  description = "FrontendのManaged Identityへ権限を付与するCosmos DB Account ID"
  type        = string
  default     = null
}

variable "create_cosmos_db_role_assignment" {
  description = "FrontendへCosmos DB SQLロールを割り当てるか"
  type        = bool
  default     = false
}