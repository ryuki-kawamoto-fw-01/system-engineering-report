output "cosmosdb_account_id" {
  description = "Cosmos DB AccountのリソースID"
  value       = azurerm_cosmosdb_account.cosmosdb.id
}