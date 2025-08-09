output "eventhub_namespace_id" {
  description = "Resource ID of the Event Hub namespace"
  value       = length(azurerm_eventhub_namespace.streaming_namespace) > 0 ? azurerm_eventhub_namespace.streaming_namespace[0].id : null
}

output "eventhub_name" {
  description = "Name of the Event Hub"
  value       = length(azurerm_eventhub.streaming_hub) > 0 ? azurerm_eventhub.streaming_hub[0].name : null
}

output "postgres_server_fqdn" {
  description = "Fully qualified domain name of the PostgreSQL server"
  value       = length(azurerm_postgresql_flexible_server.rdbms) > 0 ? azurerm_postgresql_flexible_server.rdbms[0].fqdn : null
}

output "storage_account_primary_endpoint" {
  description = "Primary blob endpoint for the storage account"
  value       = length(azurerm_storage_account.object_storage) > 0 ? azurerm_storage_account.object_storage[0].primary_blob_endpoint : null
}