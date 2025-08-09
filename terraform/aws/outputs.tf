output "kafka_arn" {
  description = "ARN of the MSK cluster"
  value       = length(aws_msk_cluster.kafka) > 0 ? aws_msk_cluster.kafka[0].arn : null
}

output "rdbms_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = length(aws_db_instance.rdbms) > 0 ? aws_db_instance.rdbms[0].endpoint : null
}

output "elasticsearch_endpoint" {
  description = "Endpoint for the OpenSearch domain"
  value       = length(aws_opensearch_domain.elasticsearch) > 0 ? aws_opensearch_domain.elasticsearch[0].endpoint : null
}

output "bucket_name" {
  description = "Name of the provisioned S3 bucket"
  value       = length(aws_s3_bucket.object_storage) > 0 ? aws_s3_bucket.object_storage[0].id : null
}

output "emr_cluster_id" {
  description = "ID of the EMR cluster"
  value       = length(aws_emr_cluster.spark) > 0 ? aws_emr_cluster.spark[0].id : null
}


## Consolidated observability output.  Returns the endpoint for whichever
## observability backend is chosen via the `observability_backend` variable.
## For Grafana this will be the workspace URL; for OpenSearch and
## Elasticsearch it is the cluster endpoint.  When no observability backend
## is provisioned (because the variable is set to an unsupported value or
## resources are disabled), the output will be null.

output "observability_endpoint" {
  description = "Endpoint of the observability backend (Grafana URL or OpenSearch/Elasticsearch endpoint)"
  value = var.observability_backend == "grafana" ? (
    # Use the workspace ID for Grafana.  The URL can be derived via the AWS console.
    length(aws_grafana_workspace.grafana) > 0 ? aws_grafana_workspace.grafana[0].id : null
  ) : var.observability_backend == "opensearch" ? (
    length(aws_opensearch_domain.observability) > 0 ? aws_opensearch_domain.observability[0].endpoint : null
  ) : (
    length(aws_elasticsearch_domain.observability) > 0 ? aws_elasticsearch_domain.observability[0].endpoint : null
  )
}