output "pubsub_topic_name" {
  description = "Name of the Pub/Sub topic"
  value       = length(google_pubsub_topic.streaming_topic) > 0 ? google_pubsub_topic.streaming_topic[0].name : null
}

output "cloudsql_connection_name" {
  description = "Connection name for the Cloud SQL instance"
  value       = length(google_sql_database_instance.rdbms) > 0 ? google_sql_database_instance.rdbms[0].connection_name : null
}

output "elasticsearch_vm_self_link" {
  description = "Self link of the Elasticsearch VM"
  value       = length(google_compute_instance.elasticsearch) > 0 ? google_compute_instance.elasticsearch[0].self_link : null
}

output "bucket_url" {
  description = "URL of the Cloud Storage bucket"
  value       = length(google_storage_bucket.object_storage) > 0 ? google_storage_bucket.object_storage[0].url : null
}

output "dataproc_cluster_id" {
  description = "ID of the Dataproc cluster"
  value       = length(google_dataproc_cluster.spark_cluster) > 0 ? google_dataproc_cluster.spark_cluster[0].id : null
}

# Export the observability VM's external IP address based on the chosen
# backend.  When no observability VM is deployed (because a different
# provider or backend is selected), this value will be null.

output "observability_external_ip" {
  description = "External IP address of the observability VM"
  value = var.observability_backend == "grafana" ? (
    length(google_compute_instance.observability_grafana) > 0 ? google_compute_instance.observability_grafana[0].network_interface[0].access_config[0].nat_ip : null
  ) : var.observability_backend == "opensearch" ? (
    length(google_compute_instance.observability_opensearch) > 0 ? google_compute_instance.observability_opensearch[0].network_interface[0].access_config[0].nat_ip : null
  ) : (
    length(google_compute_instance.observability_elasticsearch) > 0 ? google_compute_instance.observability_elasticsearch[0].network_interface[0].access_config[0].nat_ip : null
  )
}