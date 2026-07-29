# =============================================================================
# Event Grid Module - Variables
# =============================================================================

variable "resource_group_name" {
  description = "リソースグループ名"
  type        = string
}

variable "location" {
  description = "デプロイ先リージョン"
  type        = string
}

variable "storage_account_id" {
  description = "Event Grid System Topicの対象となるStorage Account ID"
  type        = string
}

variable "system_topic_name" {
  description = "Event Grid System Topic名"
  type        = string
}

# PDF Conversion Event Subscription
variable "enable_pdf_subscription" {
  description = "PDF変換用Event Subscriptionを有効化するか（Functionコードデプロイ後に有効化）"
  type        = bool
  default     = false
}

variable "pdf_subscription_name" {
  description = "PDF変換用Event Subscription名"
  type        = string
}

variable "pdf_function_id" {
  description = "PDF変換Function App ID（/subscriptions/.../sites/{siteName}/functions/{functionName}形式）"
  type        = string
  default     = ""
}

variable "pdf_container_path" {
  description = "PDF変換対象のBlobコンテナパス"
  type        = string
}

# Markdown Conversion Event Subscription
variable "enable_markdown_subscription" {
  description = "Markdown変換用Event Subscriptionを有効化するか（Functionコードデプロイ後に有効化）"
  type        = bool
  default     = false
}

variable "markdown_subscription_name" {
  description = "Markdown変換用Event Subscription名"
  type        = string
}

variable "markdown_function_id" {
  description = "Markdown変換Function App ID（/subscriptions/.../sites/{siteName}/functions/{functionName}形式）"
  type        = string
  default     = ""
}

variable "markdown_container_path" {
  description = "Markdown変換対象のBlobコンテナパス"
  type        = string
}

# Page Splitter Event Subscription
variable "enable_pagesplitter_subscription" {
  description = "Page Splitter用Event Subscriptionを有効化するか（Functionコードデプロイ後に有効化）"
  type        = bool
  default     = false
}

variable "pagesplitter_subscription_name" {
  description = "Page Splitter用Event Subscription名"
  type        = string
}

variable "pagesplitter_function_id" {
  description = "Page Splitter Function App ID（/subscriptions/.../sites/{siteName}/functions/{functionName}形式）"
  type        = string
  default     = ""
}

variable "pagesplitter_container_path" {
  description = "Page Splitter対象のBlobコンテナパス"
  type        = string
}

# Antimalware Event Subscription (将来利用想定・現状未使用)
variable "enable_antimalware_subscription" {
  description = "Antimalware Event Subscriptionを有効化するか"
  type        = bool
  default     = false
}

variable "antimalware_subscription_name" {
  description = "Antimalware用Event Subscription名"
  type        = string
  default     = "StorageAntimalwareSubscription"
}

variable "antimalware_webhook_url" {
  description = "Antimalware WebhookのURL"
  type        = string
  default     = ""
}

variable "antimalware_aad_tenant_id" {
  description = "Antimalware用Azure AD Tenant ID"
  type        = string
  default     = ""
}

variable "antimalware_aad_app_id" {
  description = "Antimalware用Azure AD Application ID"
  type        = string
  default     = ""
}

variable "included_event_types" {
  description = "サブスクリプションで対象とするイベントタイプのリスト"
  type        = list(string)
  default = [
    "Microsoft.Storage.BlobCreated",
    "Microsoft.Storage.BlobDeleted",
    "Microsoft.Storage.DirectoryCreated",
    "Microsoft.Storage.DirectoryDeleted",
    "Microsoft.Storage.BlobRenamed",
    "Microsoft.Storage.DirectoryRenamed",
    "Microsoft.Storage.BlobTierChanged",
    "Microsoft.Storage.BlobInventoryPolicyCompleted",
    "Microsoft.Storage.AsyncOperationInitiated",
    "Microsoft.Storage.LifecyclePolicyCompleted"
  ]
}

variable "diagnostic_setting_name" {
  description = "診断設定の名前"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics ワークスペースID"
  type        = string
}

variable "tags" {
  description = "リソースに付与するタグ"
  type        = map(string)
  default     = {}
}
