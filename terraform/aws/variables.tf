variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC identifier where resources will be deployed"
  type        = string
}

variable "kafka_cluster_name" {
  description = "Name of the MSK cluster"
  type        = string
}

variable "kafka_version" {
  description = "Kafka version (e.g. 2.8.2)"
  type        = string
  default     = "2.8.2"
}

variable "kafka_broker_nodes" {
  description = "Number of broker nodes for the cluster"
  type        = number
  default     = 3
}

variable "kafka_instance_type" {
  description = "Instance type for Kafka brokers"
  type        = string
  default     = "kafka.m5.large"
}

variable "kafka_subnets" {
  description = "List of subnet IDs for the MSK cluster"
  type        = list(string)
}

variable "rdbms_identifier" {
  description = "Unique identifier for the RDS instance"
  type        = string
}

variable "rdbms_engine" {
  description = "Database engine (e.g. postgres, mysql)"
  type        = string
  default     = "postgres"
}

variable "rdbms_instance_class" {
  description = "Instance class for RDS"
  type        = string
  default     = "db.t3.medium"
}

variable "rdbms_username" {
  description = "Master username for the database"
  type        = string
}

variable "rdbms_password" {
  description = "Master user password"
  type        = string
  sensitive   = true
}

variable "rdbms_allocated_storage" {
  description = "Allocated storage (GB) for RDS"
  type        = number
  default     = 20
}

variable "rdbms_subnet_group" {
  description = "Name of an existing DB subnet group"
  type        = string
}

variable "rdbms_security_groups" {
  description = "List of VPC security groups associated with the DB"
  type        = list(string)
}

variable "elasticsearch_domain_name" {
  description = "Domain name for the OpenSearch domain"
  type        = string
}

variable "elasticsearch_version" {
  description = "Version of OpenSearch (e.g. OpenSearch_1.3)"
  type        = string
  default     = "OpenSearch_1.3"
}

variable "elasticsearch_instance_type" {
  description = "Instance type for OpenSearch data nodes"
  type        = string
  default     = "m6g.large.search"
}

variable "elasticsearch_instance_count" {
  description = "Number of nodes in the OpenSearch cluster"
  type        = number
  default     = 2
}

variable "elasticsearch_volume_size" {
  description = "Size of EBS volumes attached to each node (GB)"
  type        = number
  default     = 20
}

variable "bucket_name" {
  description = "Unique name for the S3 bucket"
  type        = string
}

variable "observability_backend" {
  description = "Observability backend to deploy (grafana, elasticsearch, opensearch)"
  type        = string
  default     = "grafana"
}

variable "emr_name" {
  description = "Name for the EMR cluster"
  type        = string
}

variable "emr_release_label" {
  description = "EMR release version (e.g. emr-6.6.0)"
  type        = string
  default     = "emr-6.6.0"
}

variable "emr_instance_count" {
  description = "Total number of instances in the cluster"
  type        = number
  default     = 3
}

variable "emr_master_instance_type" {
  description = "Instance type for EMR master node"
  type        = string
  default     = "m5.xlarge"
}

variable "emr_core_instance_type" {
  description = "Instance type for EMR core nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "emr_core_instance_count" {
  description = "Number of core nodes"
  type        = number
  default     = 2
}

variable "emr_service_role" {
  description = "IAM role for EMR service"
  type        = string
}

variable "emr_job_flow_role" {
  description = "IAM role for the EC2 instances in the EMR cluster"
  type        = string
}

variable "emr_log_uri" {
  description = "S3 URI where EMR will write logs"
  type        = string
  default     = ""
}

# Feature toggles to enable or disable individual components.  Set these
# boolean variables to false to prevent the corresponding resource from
# being created.  This allows users of the framework to pick only the
# components they need on a given cloud provider.

variable "enable_kafka" {
  description = "Whether to create the MSK cluster"
  type        = bool
  default     = true
}

variable "enable_rdbms" {
  description = "Whether to create the RDS instance"
  type        = bool
  default     = true
}

variable "enable_elasticsearch" {
  description = <<EOT
Whether to create the managed OpenSearch/Elasticsearch domain.  By default the
framework deploys a self‑managed search cluster on EC2 instances or Kubernetes,
so this value can usually remain false.  Only set this to true when
`search_deployment = "domain"` and you explicitly wish to provision the AWS
OpenSearch Service domain.  When set to true and `search_deployment` is not
`domain` this flag has no effect.
EOT
  type        = bool
  default     = false
}

variable "enable_object_storage" {
  description = "Whether to create the S3 bucket"
  type        = bool
  default     = true
}

###############################
# Self-managed search variables
###############################

## Deployment method for the search engine.  Supported values are
## `instance` (self-managed cluster on EC2 instances) and `kubernetes` (self-managed
## cluster on an EKS Kubernetes cluster).  When using a self-managed
## deployment you can disable the built-in OpenSearch/Elasticsearch domain
## by setting `enable_elasticsearch` to false.
variable "search_deployment" {
  description = "Deployment method for the search engine (instance or kubernetes)"
  type        = string
  default     = "instance"
}

## Number of nodes to deploy for the self-managed search cluster.  A minimum
## of three nodes is recommended for production.  Only used when
## `search_deployment = \"instance\"`.
variable "search_node_count" {
  description = "Number of nodes in the self-managed search cluster"
  type        = number
  default     = 3
}

## Instance type to use for each node in the self-managed search cluster.
variable "search_instance_type" {
  description = "Instance type for self-managed search nodes"
  type        = string
  default     = "t3.medium"
}

## Root volume size (in GB) for each self-managed search node.
variable "search_volume_size" {
  description = "EBS volume size (GB) for self-managed search nodes"
  type        = number
  default     = 50
}

variable "enable_spark" {
  description = "Whether to create the EMR cluster"
  type        = bool
  default     = true
}

# How to deploy the Spark compute layer on AWS.  Valid values are:
#   - "serverless": use Amazon EMR Serverless (preferred)
#   - "emr_cluster": provision a traditional EMR cluster (legacy)
#   - "none": skip Spark deployment entirely
# The default is "serverless".  When set to "serverless" the module
# provisions an `aws_emrserverless_application` resource.  When set to
# "emr_cluster" it creates an `aws_emr_cluster` resource.  When set to
# "none" no Spark resources are created even if `enable_spark` is true.
variable "spark_deployment" {
  description = "Deployment method for Spark on AWS (serverless, emr_cluster or none)"
  type        = string
  default     = "serverless"
}

# Release label for EMR Serverless applications.  See the AWS documentation for
# supported values.  The default corresponds to the latest EMR 6.x series at
# the time this module was authored.  Only used when `spark_deployment` is
# "serverless".
variable "spark_serverless_release_label" {
  description = "Release label for the EMR Serverless application"
  type        = string
  default     = "emr-6.6.0"
}

# The application type for the EMR Serverless application.  For Spark jobs
# this should be set to "spark".
variable "spark_serverless_type" {
  description = "Application type for the EMR Serverless application (e.g. spark)"
  type        = string
  default     = "spark"
}

# Additional security‑related variables
#
# kafka_kms_key_arn
#   When provisioning an MSK cluster, data is encrypted at rest using a
#   customer‑managed KMS key.  Provide the ARN of your KMS key here.  If
#   omitted or left as an empty string, the cluster will fall back to the
#   AWS‑managed CMK for MSK.  Supplying your own key gives you full
#   control over rotation, deletion and access policies.

variable "kafka_kms_key_arn" {
  description = "KMS key ARN used to encrypt MSK data at rest. Leave empty to use the default AWS managed key."
  type        = string
  default     = ""
}

