# #############################################################################
# # OUTPUTS Application Insights
# #############################################################################

output "instrumentation_key" {
  description = "Intrumentation key for application insights"
  #value       = azurerm_application_insights.this.instrumentation_key
  value = { for ik in azurerm_application_insights.this : ik.name => ik.instrumentation_key }
}

output "app_id" {
  description = "App ID for application insights"
  #value       = azurerm_application_insights.this.app_id
  value = { for ik in azurerm_application_insights.this : ik.name => ik.app_id }
}
