# =============================================================================
# Environment Configuration - Resource Group / Log Analytics 単体デプロイ用
# =============================================================================

variable "subscription_id" {
  description = "AzureサブスクリプションID（sst-harc test環境）"
  type        = string
  default     = "def81dc7-dd19-48d9-a825-9aeb35274dd4"
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure ADテナントID（sst-harc test環境）"
  type        = string
  default     = "f54277c9-dafe-44aa-85a4-73d5c7c52450"
  sensitive   = true
}

variable "environment_prefix" {
  description = "リソース名に使用するプレフィックス（環境ごとに異なる）"
  type        = string
  default     = "hs"
}

variable "location_log_analytics" {
  description = "Log Analytics Workspaceのデプロイ先リージョン"
  type        = string
  default     = "japanwest"
}
