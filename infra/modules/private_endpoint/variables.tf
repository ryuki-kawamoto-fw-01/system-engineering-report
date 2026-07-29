variable "location" {
  description = "ロケーション"
  type        = string
}

variable "resource_group_name" {
  type        = string
  description = "リソースグループ名"
}

variable "subnet_id" {
  type        = string
  description = "サブネットID"
}

variable "private_endpoint_name" {
  type        = string
  description = "プライベートエンドポイント名"
}

variable "private_connection_resource_id" {
  type        = string
  description = "プライベート接続リソースID"
}

variable "subresource_names" {
  type        = list(string)
  description = "サブリソース名(リスト)"
}

variable "tags" {
  description = "タグ"
  type        = map(string)
  default     = {}
}

variable "custom_network_interface_name" {
  description = "カスタムネットワークインターフェース名（オプション）"
  type        = string
  default     = null
}

# Private DNS Zone Group Variables
variable "enable_private_dns_zone_group" {
  description = "プライベートDNSゾーングループを有効にするかどうか"
  type        = bool
  default     = true
}

variable "private_dns_zone_group_name" {
  description = "プライベートDNSゾーングループ名"
  type        = string
  default     = "default"
}

variable "private_dns_zone_ids" {
  description = "統合するプライベートDNSゾーンのIDのリスト"
  type        = list(string)
  default     = []
}
