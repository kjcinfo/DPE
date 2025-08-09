variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for regional resources"
  type        = string
}

variable "zone" {
  description = "GCP zone for zonal resources (e.g. VM)"
  type        = string
}

variable "network" {
  description = "Name of the VPC network for the VM"
  type        = string
}

variable "streaming_topic_name" {
  description = "Name of the Pub/Sub topic for streaming"
  type        = string
}

variable "rdbms_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
}

variable "rdbms_version" {
  description = "Cloud SQL database version (e.g. POSTGRES_14, MYSQL_8_0)"
  type        = string
  default     = "POSTGRES_14"
}

variable "rdbms_tier" {
  description = "Machine type for the Cloud SQL instance"
  type        = string
  default     = "db-custom-2-7680"
}

variable "rdbms_username" {
  description = "Admin username for the Cloud SQL instance"
  type        = string
}

variable "rdbms_password" {
  description = "Admin password for the Cloud SQL instance"
  type        = string
  sensitive   = true
}

variable "rdbms_database_name" {
  description = "Name of the initial database to create"
  type        = string
}

variable "elasticsearch_vm_name" {
  description = "Name of the Compute Engine instance running Elasticsearch"
  type        = string
}

variable "elasticsearch_machine_type" {
  description = "Machine type for the Elasticsearch VM"
  type        = string
  default     = "e2-standard-2"
}

variable "elasticsearch_disk_size" {
  description = "Size of the boot disk for the Elasticsearch VM (GB)"
  type        = number
  default     = 50
}

variable "bucket_name" {
  description = "Globally unique name for the Cloud Storage bucket"
  type        = string
}

variable "spark_cluster_name" {
  description = "Name of the Dataproc cluster"
  type        = string
}

variable "spark_master_machine_type" {
  description = "Machine type for Dataproc master node"
  type        = string
  default     = "n1-standard-4"
}

variable "spark_worker_machine_type" {
  description = "Machine type for Dataproc worker nodes"
  type        = string
  default     = "n1-standard-4"
}

variable "spark_worker_count" {
  description = "Number of worker nodes in the Dataproc cluster"
  type        = number
  default     = 2
}

# -----------------------------------------------------------------------------
#  Feature toggles and observability configuration
#
#  The variables below allow consumers of the framework to enable or disable
#  individual components when provisioning on GCP.  Use these toggles to
#  selectively build only the pieces of the data platform that you need.  The
#  `observability_backend` variable selects which monitoring stack to deploy.

variable "enable_streaming" {
  description = "Whether to create the Pub/Sub topic for streaming"
  type        = bool
  default     = true
}

variable "enable_rdbms" {
  description = "Whether to create the Cloud SQL instance and database"
  type        = bool
  default     = true
}

variable "enable_elasticsearch" {
  description = "Whether to create the Elasticsearch VM"
  type        = bool
  default     = true
}

variable "enable_object_storage" {
  description = "Whether to create the Cloud Storage bucket"
  type        = bool
  default     = true
}

variable "enable_spark" {
  description = "Whether to create the Dataproc cluster for Spark"
  type        = bool
  default     = true
}

variable "observability_backend" {
  description = "Observability backend to deploy (grafana, elasticsearch, opensearch)"
  type        = string
  default     = "grafana"
}

variable "observability_vm_name" {
  description = "Name of the VM instance used for the observability backend on GCP"
  type        = string
  default     = "dpe-observability"
}

variable "observability_machine_type" {
  description = "Machine type for the observability VM"
  type        = string
  default     = "e2-standard-2"
}

variable "observability_disk_size" {
  description = "Size of the boot disk for the observability VM (GB)"
  type        = number
  default     = 50
}