output "action_group_id" {
  description = "The ID of the action group"
  value       = azurerm_monitor_action_group.action_group.id
}

output "resource_health_alert_id" {
  description = "The ID of the resource health alert"
  value       = azurerm_monitor_scheduled_query_rules_alert_v2.resource_health_alert.id
}

output "service_health_alert_01_id" {
  description = "The ID of the service health alert 01"
  value       = azurerm_monitor_activity_log_alert.service_health_alert_01.id
}

output "service_health_alert_02_id" {
  description = "The ID of the service health alert 02"
  value       = azurerm_monitor_activity_log_alert.service_health_alert_02.id
}
