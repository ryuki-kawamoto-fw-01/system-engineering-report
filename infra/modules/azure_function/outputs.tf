# =============================================================================
# Azure Function Module - Outputs
# =============================================================================

output "azure_function_id" {
  description = "Azure Function AppのリソースID"
  value       = azurerm_linux_function_app.this.id
}

output "azure_function_name" {
  description = "Azure Function App名"
  value       = azurerm_linux_function_app.this.name
}

output "azure_function_default_hostname" {
  description = "Azure Function Appの既定ホスト名"
  value       = azurerm_linux_function_app.this.default_hostname
}

output "function_app_identity_principal_id" {
  description = "Azure Function AppのManaged Identity Principal ID"
  value       = azurerm_linux_function_app.this.identity[0].principal_id
}

output "managed_identity_principal_id" {
  description = "Azure Function AppのManaged Identity Principal ID"
  value       = azurerm_linux_function_app.this.identity[0].principal_id
}

output "application_insights_id" {
  description = "Application InsightsのリソースID"
  value       = azurerm_application_insights.this.id
}

output "application_insights_instrumentation_key" {
  description = "Application InsightsのInstrumentation Key"
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application InsightsのConnection String"
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}