#############################################
# AWS Serverless Spark
#
# This module provisions an EMR Serverless application when Spark is
# enabled and `spark_deployment` is set to "serverless".  EMR Serverless
# provides an on‑demand, serverless runtime for Apache Spark, so you
# only pay for the resources used by your jobs.  The application is
# configured with a name derived from the EMR cluster name and uses
# variables defined in variables.tf for the release label and
# application type.  Capacity configuration blocks (initial_capacity
# and maximum_capacity) can be added here if you wish to pre‑allocate
# workers or limit resource usage.

resource "aws_emrserverless_application" "spark" {
  count = var.enable_spark && var.spark_deployment == "serverless" ? 1 : 0

  name          = var.emr_name
  release_label = var.spark_serverless_release_label
  type          = var.spark_serverless_type

  # Optional: uncomment and customise the capacity blocks below to
  # provision pre‑initialised workers or cap resource usage.  See
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emrserverless_application
  # for more details.

  # initial_capacity {
  #   initial_capacity_type = "Driver"
  #   initial_capacity_config {
  #     worker_count       = var.spark_initial_worker_count
  #     worker_configuration {
  #       cpu    = var.spark_initial_worker_cpu
  #       memory = var.spark_initial_worker_memory
  #     }
  #   }
  # }

  # maximum_capacity {
  #   cpu    = var.spark_maximum_cpu
  #   memory = var.spark_maximum_memory
  # }

  tags = {
    Project = "DPE"
    Service = "Spark"
    Deployment = "Serverless"
  }
}