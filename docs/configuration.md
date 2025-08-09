# Configuration Reference

The Data Platforms Engine is driven by a single YAML (or JSON) file that
describes your deployment preferences.  You pass this file to the
`scripts/deploy.py` script which translates it into Terraform variables and
orchestrates the provisioning and configuration of your data platform.  A
complete example can be found in `config/config.example.yaml`.  Below is an
explanation of each top‑level key and how it affects the deployment.

## Required top‑level keys

### `cloud_provider`

Specifies the target cloud provider.  Supported values are `aws`, `gcp`
and `azure`.  Only one provider can be used at a time.  The corresponding
provider section below must also be defined.

### `data_platforms`

A map of booleans indicating which platform components to deploy.  The
available keys are:

| Key             | Description                              |
|-----------------|------------------------------------------|
| `kafka`         | Deploy the streaming layer (MSK/Pub/Sub/Event Hub) |
| `rdbms`         | Deploy the relational database (RDS/Cloud SQL/PostgreSQL Flexible Server) |
| `elasticsearch` | Deploy the search backend (OpenSearch or Elasticsearch) |
| `object_storage`| Deploy the object store (S3/GCS/Storage Account) |
| `spark`         | Deploy the Spark/ETL cluster (EMR/Dataproc/HDInsight TODO) |

If a component is set to `false` it will not be created and the associated
Terraform resources will have a count of zero.

### `configuration_management`

Choose how software should be installed and configured on the provisioned
compute instances.  Supported values are:

* `ansible` – Use the Ansible roles and playbook under `ansible/`.  This is
  the default and most feature‑complete option.
* `puppet` – Apply the Puppet manifests under `puppet/`.  These manifests
  are minimal examples and may require adaptation.
* `scripts` (or `shell`) – Fall back to executing the shell scripts in
  `scripts/`.  Each script installs a specific component using the
  operating system’s package manager.  Use this option when you do not
  have Ansible or Puppet available.

### `observability`

Controls the observability backend and collector configuration.  It is an
object with the following keys:

* `backend` – One of `grafana`, `opensearch` or `elasticsearch`.  This
  determines which backend will be deployed.  On AWS this may result in a
  managed Grafana workspace or OpenSearch domain; on GCP a VM will be
  provisioned to host the selected software.  Azure support for
  observability backends is currently a TODO.

Additional observability settings (e.g. collector endpoints, pipeline
definitions) can be customised in the Ansible role `ansible/roles/otel`.

## Provider‑specific sections

Each cloud provider requires a set of variables for networking, names and
authentication.  Only the section matching your chosen `cloud_provider` is
honoured by the deploy script.

### `aws`

| Key                      | Description |
|-------------------------|-------------|
| `region`                | AWS region in which to deploy resources (e.g. `us-east-1`) |
| `vpc_id`                | ID of an existing VPC to use.  Subnets and security groups must be created ahead of time |
| `kafka_cluster_name`    | Name of the MSK cluster |
| `kafka_subnets`         | List of subnet IDs for the Kafka brokers |
| `rdbms_identifier`      | Identifier for the RDS instance |
| `rdbms_username`        | Master username for the database |
| `rdbms_password`        | Master password (store securely!) |
| `rdbms_subnet_group`    | Name of an existing DB subnet group |
| `rdbms_security_groups` | List of security group IDs for the database |
| `elasticsearch_domain_name` | Domain name for OpenSearch |
| `bucket_name`           | Name of the S3 bucket |
| `emr_name`              | Name of the EMR cluster |
| `emr_service_role`      | IAM role used by the EMR service |
| `emr_job_flow_role`     | IAM role for the EC2 instances in the EMR cluster |
| `kafka_kms_key_arn`     | *(Optional)* ARN of a KMS key used to encrypt Kafka at rest |

### `gcp`

| Key                     | Description |
|------------------------|-------------|
| `project`              | GCP project ID |
| `region`               | Region for regional resources |
| `zone`                 | Zone for zonal resources (e.g. VMs) |
| `network`              | Name of the VPC network |
| `streaming_topic_name` | Name of the Pub/Sub topic (substitutes for Kafka) |
| `rdbms_name`           | Name of the Cloud SQL instance |
| `rdbms_username`       | Admin username |
| `rdbms_password`       | Admin password |
| `rdbms_database_name`  | Initial database to create |
| `elasticsearch_vm_name`| VM name for the Elasticsearch instance |
| `bucket_name`          | Cloud Storage bucket name |
| `spark_cluster_name`   | Name of the Dataproc cluster |

### `azure`

| Key                       | Description |
|--------------------------|-------------|
| `location`               | Azure region (e.g. `westeurope`) |
| `resource_group_name`    | Name of the resource group |
| `eventhub_namespace_name`| Event Hub namespace name |
| `eventhub_name`          | Event Hub name |
| `rdbms_name`             | Name of the PostgreSQL Flexible Server |
| `rdbms_admin_username`   | Administrator username |
| `rdbms_admin_password`   | Administrator password |
| `storage_account_name`   | Unique name for the Storage Account |

Support for Elastic and Spark on Azure is currently a TODO; you can
manually extend the Terraform files to deploy these components or
contribute improvements back to the project.

## Example

Here is a minimal configuration to deploy Kafka, PostgreSQL and S3 on AWS
using Ansible with Grafana as the observability backend:

```yaml
cloud_provider: aws
data_platforms:
  kafka: true
  rdbms: true
  elasticsearch: false
  object_storage: true
  spark: false
configuration_management: ansible
observability:
  backend: grafana
aws:
  region: us-west-2
  vpc_id: vpc-0a1b2c3d4e5f67890
  kafka_subnets:
    - subnet-0aaa1111
    - subnet-0bbb2222
    - subnet-0ccc3333
  rdbms_identifier: mydb
  rdbms_username: admin
  rdbms_password: SuperSecretPassword
  rdbms_subnet_group: my-db-subnet-group
  rdbms_security_groups:
    - sg-0123abcd
  bucket_name: my-data-bucket
  emr_name: dpe-emr
  emr_service_role: EMR_DefaultRole
  emr_job_flow_role: EMR_EC2_DefaultRole
```

Running `python3 deploy.py myconfig.yaml` with the above contents will
provision an MSK cluster, an RDS instance, an S3 bucket and a Grafana
workspace in your AWS account, then configure Kafka and PostgreSQL using
Ansible.
