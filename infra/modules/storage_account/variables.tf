variable "storage_account_name" {
  description = "ストレージアカウント名"
  type        = string
}

variable "resource_group_name" {
  description = "リソースグループ名"
  type        = string
}

variable "location" {
  description = "ロケーション"
  type        = string
}

variable "account_tier" {
  description = "アカウント階層"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "レプリケーションタイプ"
  type        = string
  default     = "LRS"
}

variable "account_kind" {
  description = "アカウント種類"
  type        = string
  default     = "StorageV2"
}

variable "min_tls_version" {
  description = "最小TLSバージョン"
  type        = string
  default     = "TLS1_2"
}

variable "https_traffic_only_enabled" {
  description = "HTTPS通信のみ許可"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "パブリックネットワークアクセスを有効化"
  type        = bool
  default     = false
}

variable "allow_blob_public_access" {
  description = "BLOBパブリックアクセスを許可"
  type        = bool
  default     = false
}

variable "network_default_action" {
  description = "ネットワークルールのデフォルトアクション"
  type        = string
  default     = "Deny"
}

variable "network_bypass" {
  description = "ネットワークバイパス"
  type        = list(string)
  default     = ["AzureServices"]
}

variable "network_ip_rules" {
  description = "許可するIPアドレス"
  type        = list(string)
  default     = []
}

variable "network_subnet_ids" {
  description = "許可するサブネットID"
  type        = list(string)
  default     = []
}

variable "blob_versioning_enabled" {
  description = "BLOBバージョニング有効化"
  type        = bool
  default     = false
}

variable "blob_change_feed_enabled" {
  description = "BLOB変更フィード有効化"
  type        = bool
  default     = false
}

variable "blob_delete_retention_days" {
  description = "BLOB削除保持期間(日)"
  type        = number
  default     = 7
}

variable "blob_container_delete_retention_days" {
  description = "BLOBコンテナー削除保持期間(日)"
  type        = number
  default     = 7
}

variable "enable_lifecycle_management" {
  description = "ライフサイクル管理を有効化"
  type        = bool
  default     = false
}

variable "lifecycle_delete_after_days" {
  description = "ライフサイクル削除期間(日)"
  type        = number
  default     = 365
}

variable "tags" {
  description = "タグ"
  type        = map(string)
  default     = {}
}

variable "containers" {
  description = "作成するストレージコンテナーのリスト"
  type = list(object({
    name                  = string
    container_access_type = string
  }))
  default = []
}

variable "queues" {
  description = "作成するストレージキューのリスト"
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "Log Analyticsワークスペースid"
  type        = string
  default     = ""
}

variable "blob_diagnostic_setting_name" {
  description = "Blob Serviceの診断設定名"
  type        = string
}

variable "queue_diagnostic_setting_name" {
  description = "Storage Queuesの診断設定名"
  type        = string
}

variable "folder_placeholders" {
  description = "コンテナー内に作成するフォルダ構造（プレースホルダーBlob）"
  type = list(object({
    container_name = string
    folder_path    = string
  }))
  default = []
}

variable "init_flag" {
  description = "初回デプロイメントフラグ（trueの場合は診断設定を作成しない）"
  type        = bool
  default     = false
}
