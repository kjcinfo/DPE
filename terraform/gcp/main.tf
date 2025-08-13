provider "google" {
  project = var.project
  region  = var.region
}

# -----------------------------------------------------------------------------
#  GCP data platform resources
#
#  This file provisions the major data platform components on Google Cloud:
#  * Streaming via Pub/Sub topics
#  * A managed relational database via Cloud SQL
#  * An Elasticsearch VM using a startup script
#  * Object storage via a Cloud Storage bucket
#  * A Spark cluster via Dataproc
# -----------------------------------------------------------------------------

resource "google_pubsub_topic" "streaming_topic" {
  count = var.enable_streaming ? 1 : 0
  name  = var.streaming_topic_name
}

resource "google_sql_database_instance" "rdbms" {
  count            = var.enable_rdbms ? 1 : 0
  name             = var.rdbms_name
  database_version = var.rdbms_version
  region           = var.region
  settings {
    tier = var.rdbms_tier
    backup_configuration {
      enabled = true
    }
  }
}

resource "google_sql_user" "rdbms_user" {
  count    = var.enable_rdbms ? 1 : 0
  name     = var.rdbms_username
  instance = google_sql_database_instance.rdbms[0].name
  password = var.rdbms_password
}

resource "google_sql_database" "rdbms_db" {
  count    = var.enable_rdbms ? 1 : 0
  name     = var.rdbms_database_name
  instance = google_sql_database_instance.rdbms[0].name
  charset  = "utf8"
  collation = "utf8_general_ci"
}

resource "google_compute_instance" "elasticsearch" {
  count        = var.enable_elasticsearch ? 1 : 0
  name         = var.elasticsearch_vm_name
  machine_type = var.elasticsearch_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20231212"
      size  = var.elasticsearch_disk_size
    }
  }

  network_interface {
    network       = var.network
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e
    # Install Elasticsearch on the VM.
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-11-jdk wget apt-transport-https
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
    echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-8.x.list
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y elasticsearch
    systemctl enable elasticsearch.service
    systemctl start elasticsearch.service
  EOF
}

resource "google_storage_bucket" "object_storage" {
  count    = var.enable_object_storage ? 1 : 0
  name     = var.bucket_name
  location = var.region
}

resource "google_dataproc_cluster" "spark_cluster" {
  # Create a Dataproc cluster only when Spark is enabled and the deployment
  # mode is set to "cluster".  When set to "serverless", no cluster is
  # created and users should submit jobs to Dataproc Serverless using
  # `gcloud dataproc batches` or the Dataproc API.  When set to "none" the
  # Spark component is completely disabled.
  count = var.enable_spark && var.spark_deployment == "cluster" ? 1 : 0
  name   = var.spark_cluster_name
  region = var.region

  cluster_config {
    master_config {
      num_instances    = 1
      machine_type_uri = var.spark_master_machine_type
    }
    worker_config {
      num_instances    = var.spark_worker_count
      machine_type_uri = var.spark_worker_machine_type
    }
  }
}