variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the Cosmos DB account"
  type        = string
}

variable "cosmosdb_account_name" {
  description = "The name of the Cosmos DB account"
  type        = string
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled"
  type        = bool
  default     = false
}

variable "enable_automatic_failover" {
  description = "Enable automatic failover for this Cosmos DB account"
  type        = bool
  default     = true
}

variable "enable_multiple_write_locations" {
  description = "Enable multiple write locations for this Cosmos DB account"
  type        = bool
  default     = false
}

variable "disable_local_auth" {
  description = "Disable local authentication methods, only allowing AAD"
  type        = bool
  default     = true
}

variable "consistency_policy" {
  description = "Consistency policy for the Cosmos DB account"
  type = object({
    consistency_level       = string
    max_interval_in_seconds = optional(number)
    max_staleness_prefix    = optional(number)
  })
  default = {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100
  }
}

variable "databases" {
  description = "List of databases to create"
  type = list(object({
    name       = string
    throughput = optional(number)
    autoscale_settings = optional(object({
      max_throughput = number
    }))
    containers = list(object({
      name               = string
      partition_key_path = string
      throughput         = optional(number)
      autoscale_settings = optional(object({
        max_throughput = number
      }))
      indexing_policy = optional(object({
        indexing_mode = string
        included_path = optional(list(object({
          path = string
        })))
        excluded_path = optional(list(object({
          path = string
        })))
      }))
      unique_key = optional(list(object({
        paths = list(string)
      })))
    }))
  }))
  default = []
}

variable "failover_locations" {
  description = "List of failover locations"
  type = list(object({
    location          = string
    failover_priority = number
    zone_redundant    = optional(bool, false)
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "enable_free_tier" {
  description = "Enable free tier for this Cosmos DB account"
  type        = bool
  default     = false
}

variable "capacity_mode" {
  description = "The capacity mode of the Cosmos DB account (Provisioned or Serverless)"
  type        = string
  default     = "Provisioned"
}

variable "minimal_tls_version" {
  description = "Specifies the minimal TLS version for the Cosmos DB account"
  type        = string
  default     = "Tls12"
}

variable "network_acl_bypass" {
  description = "Specifies the network ACL bypass for Azure services"
  type        = string
  default     = "None"
}

variable "analytical_storage_enabled" {
  description = "Enable analytical storage for this Cosmos DB account"
  type        = bool
  default     = false
}

variable "backup_policy" {
  description = "Backup policy for the Cosmos DB account"
  type = object({
    type                = string
    interval_in_minutes = optional(number)
    retention_in_hours  = optional(number)
    storage_redundancy  = optional(string)
  })
  default = {
    type                = "Periodic"
    interval_in_minutes = 240
    retention_in_hours  = 8
    storage_redundancy  = "Geo"
  }
}

variable "total_throughput_limit" {
  description = "合計アカウント スループットを制限する (-1 = 無制限, 正の整数 = 制限値)"
  type        = number
  default     = 6000
}

variable "log_analytics_workspace_id" {
  description = "診断設定用のLog Analytics Workspace ID"
  type        = string
}

variable "diagnostic_setting_name" {
  description = "診断設定の名前"
  type        = string
}
