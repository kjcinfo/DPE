/*
 * Observability backend resources for Azure
 *
 * This file acts as a placeholder for observability deployments on Azure.
 * At the time of writing, Azure offers services such as Azure Monitor,
 * Log Analytics, and Managed Grafana (preview) that could be used as
 * observability backends.  To keep the POC simple we do not provision
 * any real observability resources here.  Users can extend this file to
 * deploy an `azurerm_dashboard_grafana` or use Elastic Cloud on Azure for
 * Elasticsearch/OpenSearch.  The variables defined in variables.tf provide
 * the names and toggles necessary to integrate such resources.
 */

# TODO: Add resources for Azure Managed Grafana, Elastic Cloud on Azure or
# OpenSearch service once available.  Use the `observability_backend`
# variable to determine which service to create.  Refer to the AWS and
# GCP observability.tf examples for inspiration.
