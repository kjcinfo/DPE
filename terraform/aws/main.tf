provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
#  AWS data platform resources
#
#  This file provisions the major data platform components on AWS:
#  * Kafka via MSK (managed streaming for Apache Kafka)
#  * A relational database via RDS (PostgreSQL/MySQL)
#  * Elasticsearch via OpenSearch Service
#  * Object storage via an S3 bucket
#  * Spark via an EMR cluster
#
#  Each resource uses variables defined in variables.tf.  Adjust those values
#  according to your environment and requirements.
# -----------------------------------------------------------------------------

resource "aws_security_group" "kafka" {
  count = var.enable_kafka ? 1 : 0
  name  = "${var.kafka_cluster_name}-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_msk_cluster" "kafka" {
  count                  = var.enable_kafka ? 1 : 0
  cluster_name           = var.kafka_cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.kafka_broker_nodes

  broker_node_group_info {
    instance_type   = var.kafka_instance_type
    client_subnets  = var.kafka_subnets
    # use splat expression to handle zero security groups when kafka is disabled
    security_groups = aws_security_group.kafka[*].id
  }

  # Encrypt data at rest and enforce TLS/SASL for clients.  A KMS key ARN must
  # be provided via the kafka_kms_key_arn variable.  If no key is provided
  # encryption will use the default AWS managed CMK.
  encryption_info {
    encryption_at_rest_kms_key_arn = var.kafka_kms_key_arn
  }
  client_authentication {
    sasl {
      iam = true
    }
    tls {
      enabled = true
    }
  }

  tags = {
    Project = "DPE"
    Service = "Kafka"
  }
}

resource "aws_db_instance" "rdbms" {
  count                  = var.enable_rdbms ? 1 : 0
  identifier              = var.rdbms_identifier
  engine                  = var.rdbms_engine
  instance_class          = var.rdbms_instance_class
  username                = var.rdbms_username
  password                = var.rdbms_password
  allocated_storage       = var.rdbms_allocated_storage
  db_subnet_group_name    = var.rdbms_subnet_group
  vpc_security_group_ids  = var.rdbms_security_groups
  skip_final_snapshot     = true
  storage_encrypted       = true

  tags = {
    Project = "DPE"
    Service = "RDBMS"
  }
}

resource "aws_opensearch_domain" "elasticsearch" {
  count         = var.enable_elasticsearch ? 1 : 0
  domain_name   = var.elasticsearch_domain_name
  engine_version = var.elasticsearch_version

  cluster_config {
    instance_type  = var.elasticsearch_instance_type
    instance_count = var.elasticsearch_instance_count
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.elasticsearch_volume_size
  }

  # Enable encryption at rest and node-to-node encryption for enhanced security
  encrypt_at_rest {
    enabled = true
  }
  node_to_node_encryption {
    enabled = true
  }

  tags = {
    Project = "DPE"
    Service = "Elasticsearch"
  }
}

resource "aws_s3_bucket" "object_storage" {
  count = var.enable_object_storage ? 1 : 0
  bucket = var.bucket_name

  # Default encryption ensures all objects are encrypted at rest with AES256
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Project = "DPE"
    Service = "ObjectStorage"
  }
}

resource "aws_emr_cluster" "spark" {
  count         = var.enable_spark ? 1 : 0
  name          = var.emr_name
  release_label = var.emr_release_label
  applications  = ["Spark"]

  instances {
    instance_count                    = var.emr_instance_count
    master_instance_type              = var.emr_master_instance_type
    core_instance_type                = var.emr_core_instance_type
    core_instance_count               = var.emr_core_instance_count
    keep_job_flow_alive_when_no_steps = true
  }

  service_role  = var.emr_service_role
  job_flow_role = var.emr_job_flow_role
  log_uri       = var.emr_log_uri

  tags = {
    Project = "DPE"
    Service = "Spark"
  }
}

# Optional Grafana workspace for observability
##
## Grafana workspace creation has been migrated to `observability.tf`.  The
## managed Grafana resource is now created based on the `observability_backend`
## variable in that file.  The block below has been removed to avoid
## duplicating resources.  See `terraform/aws/observability.tf` for details.
