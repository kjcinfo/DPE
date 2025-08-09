# Data Platforms Engine (DPE)

DPE is a **Data Platform Framework** that helps teams provision and configure complete data platforms across multiple cloud providers with just a few clicks.  It is designed to be modular and extensible so that you can deploy a streaming layer, relational databases, search clusters, object storage and compute resources on **AWS**, **Google Cloud Platform** (GCP) or **Microsoft Azure** with consistent infrastructure‑as‑code and configuration management tooling.

## Goals

* **Turn‑key deployments:** Provide ready‑to‑use Terraform modules and Ansible playbooks for common data platform components such as Apache Kafka (streaming), PostgreSQL/MySQL (relational databases), Elasticsearch or OpenSearch (search and fast data access), object storage (S3/GCS/Blob Storage) and Apache Spark for ETL workloads.  The search component can be deployed either as a managed service (e.g. AWS OpenSearch Service) or as a self‑managed cluster on virtual machines or Kubernetes.  For Spark, the framework now supports serverless deployments (EMR Serverless, Dataproc Serverless/Synapse) as well as legacy cluster‑based approaches.
* **Multi‑cloud support:** Abstract provider‑specific details so you can choose between AWS, GCP or Azure by simply adjusting a handful of variables.
* **Modular design:** Each component can be enabled or disabled independently.  You can pick only the pieces you need and combine them into a cohesive platform.
* **Ease of operation:** Configuration management via Ansible ensures that compute instances are correctly configured for the chosen software.  Examples are provided for installing and managing Kafka, PostgreSQL, Elasticsearch and Spark.

## Repository layout

```
.
├── README.md                     # You are here.
├── terraform/                    # Infrastructure‑as‑code definitions
│   ├── aws/                      # AWS specific resources
│   │   ├── main.tf               # Complete AWS data platform
│   │   ├── variables.tf          # Variables for AWS resources
│   │   └── outputs.tf            # Outputs for AWS resources
│   ├── gcp/                      # Google Cloud Platform resources
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── azure/                    # Microsoft Azure resources (skeleton)
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── ansible/                      # Configuration management using Ansible
│   ├── inventory.ini             # Example inventory file
│   ├── playbook.yml              # Sample playbook to orchestrate roles
│   └── roles/                    # Individual roles for each component
│       ├── kafka/
│       │   ├── tasks/main.yml
│       │   └── handlers/main.yml
│       ├── rdbms/
│       │   ├── tasks/main.yml
│       │   └── handlers/main.yml
│       ├── elasticsearch/
│       │   ├── tasks/main.yml
│       │   └── handlers/main.yml
│       ├── spark/
│       │   ├── tasks/main.yml
│       │   └── handlers/main.yml
│       └── otel/
│           ├── defaults/main.yml
│           ├── tasks/main.yml
│           ├── handlers/main.yml
│           └── templates/otel-config.yml.j2

├── puppet/                      # Puppet modules for configuration management
│   ├── manifests/site.pp        # Example site manifest
│   └── modules/                 # Modules for each component
│       ├── kafka/
│       │   └── manifests/init.pp
│       ├── rdbms/
│       │   └── manifests/init.pp
│       ├── elasticsearch/
│       │   └── manifests/init.pp
│       └── spark/
│           └── manifests/init.pp

├── scripts/                     # Shell scripts for fallback installation
│   ├── install_kafka.sh
│   ├── install_rdbms.sh
│   ├── install_elasticsearch.sh
│   ├── install_spark.sh
│   └── install_observability.sh
├── config/                      # Deployment configuration examples
│   └── config.example.yaml      # Sample YAML config consumed by deploy.py
├── docs/                        # Project documentation
│   ├── architecture.md          # Architecture overview
│   ├── vision.md                # Vision and benefits
│   └── configuration.md         # Config file reference

```

## Getting started

1. **Create a configuration file:** Copy `config/config.example.yaml` to a new file (e.g. `myconfig.yaml`) and edit it to match your environment.  Specify the `cloud_provider` (aws/gcp/azure), the components you wish to deploy under `data_platforms`, your preferred `configuration_management` tool, the `observability` backend and any provider‑specific settings (region, VPC/network IDs, usernames, passwords, etc.).  See `docs/configuration.md` for a full reference.

2. **Run the deploy script:** Execute the provided Python script, pointing it at your configuration file.  The script will create a working directory, generate a `terraform.auto.tfvars.json` file, run the standard `terraform init`, `plan` and `apply` commands and then configure the provisioned hosts using Ansible, Puppet or shell scripts.  The deploy script reads variables such as `search_deployment` to decide whether to deploy a fully managed AWS OpenSearch domain or a self‑managed Elasticsearch/OpenSearch cluster on EC2 or Kubernetes.

   ```bash
   python3 scripts/deploy.py myconfig.yaml
   ```

   Terraform will provision the required infrastructure components on your chosen cloud provider.  The deploy script will then run Ansible, Puppet or scripts to install and configure Kafka, databases, Elasticsearch, Spark and the OpenTelemetry collector.

3. **Inspect outputs:** The deploy script prints the Terraform outputs as a JSON object at the end of the run.  These include endpoints and identifiers that you may need to connect to the deployed services.

4. **Extend as needed:** This repository is a starting point.  Feel free to add additional Terraform modules (e.g. Redis, Cassandra) or Ansible roles as your data platform grows.  Contributions are welcome!

5. **Choose your configuration management and observability options:** The framework supports **Ansible** (default), **Puppet**, or bare **shell scripts**.  Use the roles and playbook in `ansible/`, the manifests in `puppet/`, or the scripts in `scripts/` depending on your preferred tool.  Observability is built in via the OpenTelemetry collector role.  Choose `grafana`, `opensearch` or `elasticsearch` as your `observability.backend` to provision a suitable backend on each cloud.  On AWS this may be a managed Grafana workspace; on GCP an additional VM is created; on Azure observability is currently a TODO.

## Caveats

* The Azure implementation includes basic examples for Event Hub, PostgreSQL Flexible Server, Storage Accounts and a skeleton for deploying an Elasticsearch VM and Spark cluster.  Networking (VNET, subnet and security groups) has been omitted for brevity; you should tailor these resources to your organisation’s standards.
* Default values have intentionally been kept minimal.  Always review resource sizes, retention periods and security settings before applying these templates in production environments.

* **Feature toggles:** Terraform variables such as `enable_kafka`, `enable_rdbms`, `enable_elasticsearch`, `enable_object_storage` and `enable_spark` (as well as provider‑specific toggles like `enable_streaming` on GCP and Azure) allow you to disable individual components.  When a component is disabled the corresponding resources will not be created and outputs will return `null`.  Additional deployment modes can be selected via variables like `spark_deployment` (e.g. `serverless`, `emr_cluster` or `none` on AWS and `cluster` or `serverless` on GCP) and `search_deployment` to fine‑tune how each component is provisioned.

* **Observability:** The provided OpenTelemetry role installs the collector and configures it to send metrics and traces to your chosen backend.  Only minimal configuration is included – you should customise the collector configuration (`otel-config.yaml`) to align with your monitoring stack.  Observability on AWS is provisioned via the `observability_backend` variable and may create a managed Grafana workspace, a managed OpenSearch/Elasticsearch domain or, preferably, use the same self‑managed search cluster deployed for your search use cases.  On GCP the backend is deployed on a Compute Engine VM, and Azure support is currently a TODO.

* **Puppet and scripts:** The Puppet manifests and shell scripts in this repository serve as simple examples.  They are not feature complete and may require adaptation for production use.  You may also need to supply your own Puppet control repo or orchestration when deploying at scale.

## License

MIT License.  See `LICENSE` file for details.
