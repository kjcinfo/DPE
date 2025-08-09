# Architecture Overview

The Data Platforms Engine (DPE) is designed to provide a consistent,
multi‑cloud framework for deploying common data platform components.  Its
architecture is intentionally modular so that users can choose only the
services they need while maintaining a unified deployment experience across
Amazon Web Services (AWS), Google Cloud Platform (GCP) and Microsoft Azure.

## Core components

| Component               | Purpose                                                   | Terraform resources                |
|------------------------|-----------------------------------------------------------|------------------------------------|
| **Streaming**          | Real‑time data ingestion via Kafka (MSK), Pub/Sub or Event Hub | `aws_msk_cluster`, `google_pubsub_topic`, `azurerm_eventhub_namespace`/`eventhub` |
| **Relational database**| Transactional store for structured data                   | `aws_db_instance`, `google_sql_database_instance`, `azurerm_postgresql_flexible_server` |
| **Search**             | Fast search and analytics using Elasticsearch/OpenSearch   | `aws_opensearch_domain`, `google_compute_instance` (Elasticsearch VM), *Azure TODO* |
| **Object storage**     | Durable storage for files, logs and staging data          | `aws_s3_bucket`, `google_storage_bucket`, `azurerm_storage_account` |
| **ETL/Analytics**      | Batch and streaming processing with Spark                 | `aws_emr_cluster`, `google_dataproc_cluster`, *Azure TODO* |
| **Observability**      | Metrics and tracing via OpenTelemetry collector and backend | `aws_grafana_workspace`/`aws_opensearch_domain`/`aws_elasticsearch_domain`, GCP/VM backends, *Azure TODO* |

Each component has a corresponding **feature toggle** (e.g. `enable_kafka`, `enable_rdbms`) which allows the module to be enabled or disabled independently.  When a toggle is set to `false`, Terraform will not create any resources for that component and the corresponding outputs will return `null`.

## Multi‑cloud workflow

1. **Select a cloud provider:** Choose between `aws`, `gcp` or `azure` in your configuration file.  The `deploy.py` script will copy the appropriate Terraform module into a working directory and inject variables via a generated `terraform.auto.tfvars.json` file.

2. **Provision infrastructure with Terraform:** Each provider directory (`terraform/aws`, `terraform/gcp`, `terraform/azure`) contains a complete set of resources for the platform components.  Terraform handles the lifecycle of VPCs/networks, compute instances, managed services and storage.

3. **Configure software with your preferred tool:** Once compute resources are provisioned, apply configuration using **Ansible** (default), **Puppet** or simple shell scripts.  Roles and manifests are provided for Kafka, databases, Elasticsearch, Spark and OpenTelemetry.  You can also supply your own playbooks or modules.

4. **Observability pipeline:** The OpenTelemetry collector role installs and configures the collector on target hosts.  Metrics and traces can be sent to your chosen backend (Grafana, OpenSearch or Elasticsearch).  On AWS the framework can optionally provision a managed Grafana workspace; on GCP a VM is created to host the observability backend; Azure support is planned via Managed Grafana or Elastic Cloud.

## Security considerations

Security is a first‑class concern throughout the DPE:

* **Encryption at rest:** All data stores created by Terraform enable encryption.  RDS instances set `storage_encrypted = true`; S3 buckets use server‑side encryption; OpenSearch domains enable encryption at rest and node‑to‑node encryption.  Kafka clusters can be encrypted with a customer‑managed KMS key via the `kafka_kms_key_arn` variable.

* **Secure networking:** The modules assume resources are deployed inside existing VPCs or networks specified via variables (`vpc_id` on AWS, `network` on GCP).  You should restrict inbound and outbound traffic using security groups, firewall rules and private subnets.  The sample Terraform files omit detailed network configuration to keep the POC simple – customise them to meet your organisation’s standards.

* **Least privilege IAM:** Terraform expects you to supply IAM roles and policies (e.g. for EMR service roles or GCP service accounts).  Limit the permissions granted to these roles to only those required by the services they support.

* **Secret management:** Database passwords and other sensitive values are declared as `sensitive` variables in Terraform.  Use secret managers (AWS Secrets Manager, GCP Secret Manager, Azure Key Vault) to store and retrieve secrets instead of hard‑coding them in configuration files.

By combining infrastructure‑as‑code with configuration management and observability, the DPE aims to provide a secure, reproducible foundation for modern data architectures.
