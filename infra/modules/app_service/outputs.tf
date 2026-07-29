# =============================================================================
# App Service Module - Outputs
# =============================================================================

output "app_service_plan_01_id" {
  description = "App Service Plan 01のリソースID"
  value       = azurerm_service_plan.plan_01.id
}

output "app_service_plan_01_name" {
  description = "App Service Plan 01の名前"
  value       = azurerm_service_plan.plan_01.name
}

output "app_service_plan_02_id" {
  description = "App Service Plan 02のリソースID"
  value       = azurerm_service_plan.plan_02.id
}

output "app_service_plan_02_name" {
  description = "App Service Plan 02の名前"
  value       = azurerm_service_plan.plan_02.name
}

output "frontend_app_service_id" {
  description = "Frontend App ServiceのリソースID"
  value       = azurerm_linux_web_app.frontend.id
}

output "frontend_app_service_name" {
  description = "Frontend App Service名"
  value       = azurerm_linux_web_app.frontend.name
}

output "frontend_app_service_default_hostname" {
  description = "Frontend App Serviceの既定ホスト名"
  value       = azurerm_linux_web_app.frontend.default_hostname
}

output "frontend_app_service_identity_principal_id" {
  description = "Frontend App ServiceのManaged Identity Principal ID"
  value       = azurerm_linux_web_app.frontend.identity[0].principal_id
}

output "loadbalancer_app_service_id" {
  description = "Load Balancer App ServiceのリソースID"
  value       = azurerm_linux_web_app.loadbalancer.id
}

output "loadbalancer_app_service_name" {
  description = "Load Balancer App Service名"
  value       = azurerm_linux_web_app.loadbalancer.name
}

output "loadbalancer_app_service_default_hostname" {
  description = "Load Balancer App Serviceの既定ホスト名"
  value       = azurerm_linux_web_app.loadbalancer.default_hostname
}

output "loadbalancer_app_service_identity_principal_id" {
  description = "Load Balancer App ServiceのManaged Identity Principal ID"
  value       = azurerm_linux_web_app.loadbalancer.identity[0].principal_id
}