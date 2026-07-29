# =============================================================================
# Event Grid Module - Outputs
# =============================================================================

output "system_topic_id" {
  description = "Event Grid System TopicのリソースID"
  value       = azurerm_eventgrid_system_topic.system_topic.id
}

output "system_topic_name" {
  description = "Event Grid System Topic名"
  value       = azurerm_eventgrid_system_topic.system_topic.name
}

output "system_topic_identity" {
  description = "Event Grid System Topicのマネージドアイデンティティ"
  value       = azurerm_eventgrid_system_topic.system_topic.identity
}
