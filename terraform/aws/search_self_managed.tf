###
### Self‑managed search cluster for observability and search
###

## Retrieve the most recent Amazon Linux 2 AMI for x86_64.  This image is
## used for self‑managed search nodes when running on EC2 instances.  In
## production you may wish to use a hardened AMI or bake a custom AMI with
## Elasticsearch/OpenSearch preinstalled.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

## Security group to allow communication with the search cluster.  This
## configuration opens port 9200 for HTTP access from any source for
## demonstration purposes.  In a production environment you should
## restrict ingress to trusted CIDR blocks or security groups.
resource "aws_security_group" "search_self_managed" {
  count  = var.enable_elasticsearch && var.search_deployment == "instance" ? 1 : 0
  name   = "dpe-search-self-managed"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "DPE"
    Service = "Search"
  }
}

## EC2 instances forming the self‑managed search cluster.  The number of
## nodes is controlled by `var.search_node_count`.  Each instance runs
## Amazon Linux 2 and can be configured via user_data or configuration
## management to install and configure the desired search engine.  The
## instances are distributed across the existing Kafka subnets to improve
## availability.  In production you may wish to use dedicated subnets.
resource "aws_instance" "search_self_managed" {
  count = var.enable_elasticsearch && var.search_deployment == "instance" ? var.search_node_count : 0

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.search_instance_type
  subnet_id     = element(var.kafka_subnets, count.index % length(var.kafka_subnets))
  vpc_security_group_ids = [aws_security_group.search_self_managed[0].id]

  root_block_device {
    volume_size           = var.search_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name    = "dpe-search-${count.index}"
    Project = "DPE"
    Service = "Search"
  }

  # TODO: Add `user_data` or provisioner scripts to install and configure
  # Elasticsearch or OpenSearch.  Alternatively use Ansible or Puppet roles
  # defined in this repository to bootstrap the cluster.
}

## Placeholder for Kubernetes deployment.  When `search_deployment` is set to
## "kubernetes", users should provision an EKS cluster (using an existing
## module or the `aws_eks_cluster` resource) and deploy Elasticsearch or
## OpenSearch via Helm charts or Kubernetes manifests.  This implementation
## is left as a TODO for future work.
# TODO: Implement Kubernetes (EKS) deployment for the search cluster when
# `search_deployment = "kubernetes"`.