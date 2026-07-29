# =============================================================================
# Key Vault Module - Variables
# =============================================================================

variable "resource_group_name" {
  description = "Key Vaultを配置するリソースグループ名"
  type        = string
}

variable "location" {
  description = "Key Vaultのデプロイ先リージョン"
  type        = string
}

variable "key_vault_name" {
  description = "Key Vaultの名前"
  type        = string
}

variable "sku_name" {
  description = "Key VaultのSKU (standard, premium)"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKUは standard または premium を指定してください"
  }
}

variable "tenant_id" {
  description = "Azure AD テナントID"
  type        = string
}

variable "rbac_authorization_enabled" {
  description = "RBACベースのアクセス制御を有効にするか（falseの場合はアクセスポリシーを使用）"
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "ソフト削除の保持期間（7〜90日）"
  type        = number
  default     = 90
  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "ソフト削除の保持期間は7〜90日の範囲で指定してください"
  }
}

variable "purge_protection_enabled" {
  description = "パージ保護を有効にするか"
  type        = bool
  default     = false
}

variable "access_policies" {
  description = "Key Vaultのアクセスポリシー（RBAC無効時に使用）"
  type = list(object({
    tenant_id               = string
    object_id              = string
    key_permissions         = list(string)
    secret_permissions      = list(string)
    certificate_permissions = list(string)
  }))
  default = []
}

variable "public_network_access_enabled" {
  description = "パブリックネットワークアクセスを許可するか"
  type        = bool
  default     = true
}

variable "tags" {
  description = "リソースに付与するタグ"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Key Vaultに登録するシークレットのマップ（キー: シークレット名、値: シークレット値）"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "enable_diagnostic_setting" {
  description = "診断設定を有効にするか"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics WorkspaceのリソースID（診断設定用）"
  type        = string
  default     = null
}

variable "diagnostic_setting_name" {
  description = "診断設定の名前（未指定の場合は自動生成）"
  type        = string
  default     = null
}

variable "enabled_for_deployment" {
  description = "Azure Virtual MachinesによるKey Vault内の証明書取得を許可するか"
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Azure Disk EncryptionによるKey Vault利用を許可するか"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "ARM TemplateによるKey Vault Secret参照を許可するか"
  type        = bool
  default     = false
}

variable "init_flag" {
  description = "初期構築フェーズかどうか。trueでは構築用に開放し、falseではネットワーク制限を適用する"
  type        = bool
  default     = true
}

variable "network_acls_virtual_network_subnet_ids" {
  description = "ネットワークACLで許可する仮想ネットワークサブネットID"
  type        = list(string)
  default     = []
}