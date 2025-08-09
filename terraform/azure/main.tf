provider "azurerm" {
  features {}
}

# -----------------------------------------------------------------------------
#  Azure data platform resources (skeleton)
#
#  This example provisions a basic set of Azure resources for a data platform:
#  * Event Hub namespace and hub for streaming
#  * PostgreSQL Flexible Server for relational data
#  * Storage Account for object storage
#
#  The Elasticsearch and Spark components are left as a TODO.  Deploying these
#  components on Azure typically requires additional networking resources
#  (virtual networks, subnets and network interfaces) as well as either
#  marketplace offerings (e.g. Elastic Cloud) or HDInsight/Databricks for Spark.
#  The variables below define the names and parameters required for the existing
#  resources.
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_eventhub_namespace" "streaming_namespace" {
  count = var.enable_streaming ? 1 : 0
  name  = var.eventhub_namespace_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
}

resource "azurerm_eventhub" "streaming_hub" {
  count = var.enable_streaming ? 1 : 0
  name  = var.eventhub_name
  namespace_name      = azurerm_eventhub_namespace.streaming_namespace[0].name
  resource_group_name = azurerm_resource_group.main.name
  partition_count     = var.eventhub_partition_count
  message_retention   = var.eventhub_message_retention
}

resource "azurerm_postgresql_flexible_server" "rdbms" {
  count                  = var.enable_rdbms ? 1 : 0
  name                    = var.rdbms_name
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  version                 = var.rdbms_version
  sku_name                = var.rdbms_sku
  administrator_login     = var.rdbms_admin_username
  administrator_password   = var.rdbms_admin_password
  storage_mb              = var.rdbms_storage_mb
  backup_retention_days   = 7
}

resource "azurerm_storage_account" "object_storage" {
  count                   = var.enable_object_storage ? 1 : 0
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# TODO: Add Elasticsearch deployment (e.g. Elastic Cloud or VM) and Spark cluster
# (HDInsight or Databricks) resources here.  These components typically require
# additional networking configuration and may incur extra cost.