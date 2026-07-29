output "resource_group_name" {
  description = "リソースグループ名"
  value       = module.common.resource_group_name
}

output "resource_group_id" {
  description = "リソースグループID"
  value       = module.common.resource_group_id
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = module.log_analytics.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace名"
  value       = local.log_name
}
