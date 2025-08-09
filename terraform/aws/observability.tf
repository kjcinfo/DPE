variable "grafana_workspace_name" {
  description = "Name for the managed Grafana workspace"
  type        = string
  default     = "dpe-grafana"
}

resource "aws_grafana_workspace" "grafana" {
  count                = var.observability_backend == "grafana" ? 1 : 0
  account_access_type   = "CURRENT_ACCOUNT"
  name                 = var.grafana_workspace_name
  authentication_providers = ["AWS_SSO"]
}

resource "aws_opensearch_domain" "observability" {
  count         = var.observability_backend == "opensearch" ? 1 : 0
  domain_name   = "dpe-observability"
  engine_version = "OpenSearch_1.3"
  cluster_config {
    instance_type  = "m6g.large.search"
    instance_count = 2
  }
  ebs_options {
    ebs_enabled = true
    volume_size = 20
  }
  encrypt_at_rest {
    enabled = true
  }
  node_to_node_encryption {
    enabled = true
  }
  tags = {
    Project = "DPE"
    Service = "Observability"
  }
}

resource "aws_elasticsearch_domain" "observability" {
  count         = var.observability_backend == "elasticsearch" ? 1 : 0
  domain_name   = "dpe-elastic-observability"
  elasticsearch_version = "7.10"
  cluster_config {
    instance_type  = "m5.large.elasticsearch"
    instance_count = 2
  }
  ebs_options {
    ebs_enabled = true
    volume_size = 20
  }
  encrypt_at_rest {
    enabled = true
  }
  node_to_node_encryption {
    enabled = true
  }
  tags = {
    Project = "DPE"
    Service = "Observability"
  }
}