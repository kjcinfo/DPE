variable "location" {
  description = "Azure region in which resources will be created (e.g. westeurope)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace"
  type        = string
}

variable "eventhub_name" {
  description = "Name of the Event Hub"
  type        = string
}

variable "eventhub_partition_count" {
  description = "Number of partitions for the Event Hub"
  type        = number
  default     = 2
}

variable "eventhub_message_retention" {
  description = "Message retention period (in days)"
  type        = number
  default     = 1
}

variable "rdbms_name" {
  description = "Name of the PostgreSQL Flexible Server"
  type        = string
}

variable "rdbms_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "14"
}

variable "rdbms_sku" {
  description = "SKU name for the flexible server (e.g. Standard_D4s_v3)"
  type        = string
  default     = "Standard_B1ms"
}

variable "rdbms_admin_username" {
  description = "Administrator username for the database"
  type        = string
}

variable "rdbms_admin_password" {
  description = "Administrator password for the database"
  type        = string
  sensitive   = true
}

variable "rdbms_storage_mb" {
  description = "Allocated storage for the database (in MB)"
  type        = number
  default     = 32768
}

variable "storage_account_name" {
  description = "Globally unique name for the storage account"
  type        = string
}

# -----------------------------------------------------------------------------
#  Feature toggles and observability configuration
#
#  These variables allow you to enable or disable specific components when
#  deploying to Azure.  Set a toggle to `false` to skip creating the
#  corresponding resource.  The `observability_backend` variable determines
#  which monitoring stack to deploy.  At present, observability resources are
#  not implemented and are left as a TODO.

variable "enable_streaming" {
  description = "Whether to create the Event Hub namespace and hub"
  type        = bool
  default     = true
}

variable "enable_rdbms" {
  description = "Whether to create the PostgreSQL Flexible Server"
  type        = bool
  default     = true
}

variable "enable_object_storage" {
  description = "Whether to create the Storage Account"
  type        = bool
  default     = true
}

variable "enable_elasticsearch" {
  description = "Whether to deploy an Elasticsearch cluster (TODO)"
  type        = bool
  default     = false
}

variable "enable_spark" {
  description = "Whether to deploy a Spark cluster (TODO)"
  type        = bool
  default     = false
}

variable "observability_backend" {
  description = "Observability backend to deploy on Azure (grafana, elasticsearch, opensearch)"
  type        = string
  default     = "grafana"
}

variable "observability_workspace_name" {
  description = "Name of the observability workspace or VM (placeholder)"
  type        = string
  default     = "dpe-observability"
}