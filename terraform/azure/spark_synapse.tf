#############################################
# Azure Synapse Spark Serverless (Placeholder)
#
# The Data Platform Engine intends to support serverless Spark on Azure via
# Synapse Analytics.  At present, this file serves as a placeholder.  When
# `spark_deployment` is set to "synapse" and `enable_spark` is true, no
# resources will be created.  Users should manually provision a Synapse
# workspace and Spark pool or use the `azurerm_synapse_spark_pool` resource
# from the azurerm provider.  Additional variables and resources will be
# added here in a future release.

/*
resource "azurerm_synapse_spark_pool" "spark" {
  count = var.enable_spark && var.spark_deployment == "synapse" ? 1 : 0
  name                         = "dpe-spark"
  synapse_workspace_id         = azurerm_synapse_workspace.main.id
  node_size                    = "Small"
  node_count                  = 3
  auto_pause_enabled           = true
  auto_pause_delay_in_minutes  = 15
}
*/