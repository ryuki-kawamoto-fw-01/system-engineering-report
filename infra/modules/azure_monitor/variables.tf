variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Action Group variables
variable "action_group_name" {
  description = "The name of the action group"
  type        = string
}

variable "action_group_short_name" {
  description = "The short name of the action group"
  type        = string
}

variable "action_group_enabled" {
  description = "Whether the action group is enabled"
  type        = bool
  default     = true
}

variable "email_receivers" {
  description = "List of email receivers"
  type = list(object({
    name                    = string
    email_address           = string
    use_common_alert_schema = bool
  }))
  default = []
}

# Resource Health Alert variables
variable "resource_health_alert_name" {
  description = "The name of the resource health alert"
  type        = string
}

variable "resource_health_evaluation_frequency" {
  description = "How often the scheduled query rule is evaluated"
  type        = string
  default     = "PT5M"
}

variable "resource_health_window_duration" {
  description = "The period of time on which the Alert query will be executed"
  type        = string
  default     = "PT5M"
}

variable "resource_health_scopes" {
  description = "List of resource IDs to scope the alert to"
  type        = list(string)
}

variable "resource_health_severity" {
  description = "Severity of the alert"
  type        = number
  default     = 1
}

variable "resource_health_enabled" {
  description = "Whether the alert is enabled"
  type        = bool
  default     = true
}

variable "resource_health_auto_mitigation" {
  description = "Whether to auto mitigate the alert"
  type        = bool
  default     = true
}

variable "resource_health_query" {
  description = "The query for the resource health alert"
  type        = string
}

# Service Health Alert 01 variables
variable "service_health_alert_01_name" {
  description = "The name of the service health alert 01"
  type        = string
}

variable "service_health_scopes" {
  description = "List of subscription scopes for service health alerts"
  type        = list(string)
}

variable "service_health_01_enabled" {
  description = "Whether the service health alert 01 is enabled"
  type        = bool
  default     = true
}

variable "service_health_01_events" {
  description = "List of service health events to monitor"
  type        = list(string)
  default     = ["Incident", "Maintenance", "Informational", "ActionRequired", "Security"]
}

variable "service_health_01_locations" {
  description = "List of locations to monitor for service health alert 01"
  type        = list(string)
}

variable "service_health_01_services" {
  description = "List of services to monitor for service health alert 01"
  type        = list(string)
}

# Service Health Alert 02 variables
variable "service_health_alert_02_name" {
  description = "The name of the service health alert 02"
  type        = string
}

variable "service_health_02_enabled" {
  description = "Whether the service health alert 02 is enabled"
  type        = bool
  default     = true
}

variable "service_health_02_events" {
  description = "List of service health events to monitor"
  type        = list(string)
  default     = ["Incident", "Maintenance", "Informational", "ActionRequired", "Security"]
}

variable "service_health_02_locations" {
  description = "List of locations to monitor for service health alert 02"
  type        = list(string)
}

variable "service_health_02_services" {
  description = "List of services to monitor for service health alert 02"
  type        = list(string)
}
