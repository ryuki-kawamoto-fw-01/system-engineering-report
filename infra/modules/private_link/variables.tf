/**
 * Private Link Module Variables
 * Private Link Serviceのパラメータを定義
 */

variable "resource_group_name" {
  description = "Private Link Serviceを配置するリソースグループの名前"
  type        = string
}

variable "location" {
  description = "リソースのロケーション（例: japaneast）"
  type        = string
  default     = "japaneast"
}

variable "private_link_service_name" {
  description = "Private Link Serviceの名前"
  type        = string
}

variable "load_balancer_frontend_ip_configuration_ids" {
  description = "Load BalancerのフロントエンドIP構成IDのリスト"
  type        = list(string)
}

variable "nat_ip_configurations" {
  description = "NAT IP構成のリスト"
  type = list(object({
    name                       = string
    subnet_id                  = string
    primary                    = bool
    private_ip_address         = optional(string)
    private_ip_address_version = optional(string, "IPv4")
  }))
  validation {
    condition     = length(var.nat_ip_configurations) > 0
    error_message = "少なくとも1つのNAT IP構成が必要です。"
  }
}

variable "auto_approval_subscription_ids" {
  description = "自動承認するサブスクリプションIDのリスト"
  type        = list(string)
  default     = []
}

variable "visibility_subscription_ids" {
  description = "Private Link Serviceを表示するサブスクリプションIDのリスト"
  type        = list(string)
  default     = []
}

variable "enable_proxy_protocol" {
  description = "TCP Proxyプロトコルを有効化するか"
  type        = bool
  default     = false
}

variable "fqdns" {
  description = "Private Link ServiceのFQDNリスト"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "リソースに付与するタグ"
  type        = map(string)
  default     = {}
}
