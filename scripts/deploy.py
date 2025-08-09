#!/usr/bin/env python3
"""
deploy.py
============

This script orchestrates the deployment of a data platform based on a
user‑supplied configuration file.  It reads a YAML configuration that
describes the desired cloud provider, enabled components, configuration
management tool and observability backend, then drives Terraform and
post‑provisioning steps accordingly.  The goal of this script is to hide
the complexity of coordinating multiple tools behind a single command.  You
can run it like so:

    python3 deploy.py config.yaml

The configuration file format is documented in `docs/configuration.md`.
This script does not perform extensive error checking and is intended as a
reference implementation; adapt it to your environment as needed.
"""

import argparse
import json
import os
import subprocess
import sys

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None


def read_config(path: str) -> dict:
    """Load a configuration file in YAML or JSON format."""
    with open(path, 'r', encoding='utf-8') as fh:
        content = fh.read()
    # try YAML first if available
    if yaml is not None:
        return yaml.safe_load(content)
    # fall back to JSON
    return json.loads(content)


def run_cmd(cmd: list, cwd: str | None = None) -> None:
    """Run a command and stream its output.  Raises on error."""
    print(f"[DPE] Executing: {' '.join(cmd)}")
    proc = subprocess.Popen(cmd, cwd=cwd)
    proc.communicate()
    if proc.returncode != 0:
        raise RuntimeError(f"Command failed with exit code {proc.returncode}: {' '.join(cmd)}")


def build_tfvars(config: dict, provider: str) -> dict:
    """Translate high‑level config keys into Terraform variables."""
    tfvars: dict = {}
    platforms = config.get('data_platforms', {})
    # Generic feature toggles
    if provider == 'aws':
        tfvars['enable_kafka'] = bool(platforms.get('kafka', False))
        tfvars['enable_rdbms'] = bool(platforms.get('rdbms', False))
        tfvars['enable_elasticsearch'] = bool(platforms.get('elasticsearch', False))
        tfvars['enable_object_storage'] = bool(platforms.get('object_storage', False))
        tfvars['enable_spark'] = bool(platforms.get('spark', False))
        # Observability backend
        tfvars['observability_backend'] = config.get('observability', {}).get('backend', 'grafana')
        # Required AWS vars
        aws = config.get('aws', {})
        tfvars['aws_region'] = aws.get('region')
        tfvars['vpc_id'] = aws.get('vpc_id')
        # Example names; override as needed
        tfvars['kafka_cluster_name'] = aws.get('kafka_cluster_name', 'dpe-kafka')
        tfvars['kafka_subnets'] = aws.get('kafka_subnets', [])
        tfvars['rdbms_identifier'] = aws.get('rdbms_identifier', 'dpe-db')
        tfvars['rdbms_username'] = aws.get('rdbms_username', 'admin')
        tfvars['rdbms_password'] = aws.get('rdbms_password', 'changeme')
        tfvars['rdbms_subnet_group'] = aws.get('rdbms_subnet_group', '')
        tfvars['rdbms_security_groups'] = aws.get('rdbms_security_groups', [])
        tfvars['elasticsearch_domain_name'] = aws.get('elasticsearch_domain_name', 'dpe-search')
        tfvars['bucket_name'] = aws.get('bucket_name', 'dpe-bucket')
        tfvars['emr_name'] = aws.get('emr_name', 'dpe-emr')
        tfvars['emr_service_role'] = aws.get('emr_service_role', '')
        tfvars['emr_job_flow_role'] = aws.get('emr_job_flow_role', '')
        tfvars['emr_subnet_id'] = aws.get('emr_subnet_id', '')
        # Optionally specify KMS key for Kafka encryption
        if aws.get('kafka_kms_key_arn'):
            tfvars['kafka_kms_key_arn'] = aws['kafka_kms_key_arn']
    elif provider == 'gcp':
        tfvars['enable_streaming'] = bool(platforms.get('kafka', False))  # Pub/Sub substitute
        tfvars['enable_rdbms'] = bool(platforms.get('rdbms', False))
        tfvars['enable_elasticsearch'] = bool(platforms.get('elasticsearch', False))
        tfvars['enable_object_storage'] = bool(platforms.get('object_storage', False))
        tfvars['enable_spark'] = bool(platforms.get('spark', False))
        tfvars['observability_backend'] = config.get('observability', {}).get('backend', 'grafana')
        gcp = config.get('gcp', {})
        tfvars['project'] = gcp.get('project')
        tfvars['region'] = gcp.get('region')
        tfvars['zone'] = gcp.get('zone')
        tfvars['network'] = gcp.get('network')
        tfvars['streaming_topic_name'] = gcp.get('streaming_topic_name', 'dpe-stream')
        tfvars['rdbms_name'] = gcp.get('rdbms_name', 'dpe-db')
        tfvars['rdbms_username'] = gcp.get('rdbms_username', 'admin')
        tfvars['rdbms_password'] = gcp.get('rdbms_password', 'changeme')
        tfvars['rdbms_database_name'] = gcp.get('rdbms_database_name', 'dpe')
        tfvars['elasticsearch_vm_name'] = gcp.get('elasticsearch_vm_name', 'dpe-search')
        tfvars['bucket_name'] = gcp.get('bucket_name', 'dpe-bucket')
        tfvars['spark_cluster_name'] = gcp.get('spark_cluster_name', 'dpe-spark')
    elif provider == 'azure':
        tfvars['enable_streaming'] = bool(platforms.get('kafka', False))
        tfvars['enable_rdbms'] = bool(platforms.get('rdbms', False))
        tfvars['enable_object_storage'] = bool(platforms.get('object_storage', False))
        tfvars['enable_elasticsearch'] = bool(platforms.get('elasticsearch', False))
        tfvars['enable_spark'] = bool(platforms.get('spark', False))
        tfvars['observability_backend'] = config.get('observability', {}).get('backend', 'grafana')
        azure = config.get('azure', {})
        tfvars['location'] = azure.get('location')
        tfvars['resource_group_name'] = azure.get('resource_group_name', 'dpe-rg')
        tfvars['eventhub_namespace_name'] = azure.get('eventhub_namespace_name', 'dpe-namespace')
        tfvars['eventhub_name'] = azure.get('eventhub_name', 'dpe-hub')
        tfvars['rdbms_name'] = azure.get('rdbms_name', 'dpe-db')
        tfvars['rdbms_admin_username'] = azure.get('rdbms_admin_username', 'admin')
        tfvars['rdbms_admin_password'] = azure.get('rdbms_admin_password', 'changeme')
        tfvars['storage_account_name'] = azure.get('storage_account_name', 'dpeaccount')
    return tfvars


def write_tfvars_file(tfvars: dict, dest_dir: str) -> str:
    """Write variables to a Terraform tfvars JSON file and return its path."""
    path = os.path.join(dest_dir, 'terraform.auto.tfvars.json')
    with open(path, 'w', encoding='utf-8') as fh:
        json.dump(tfvars, fh, indent=2)
    return path


def main() -> None:
    parser = argparse.ArgumentParser(description="Deploy the DPE data platform from a config file")
    parser.add_argument('config', help='Path to configuration YAML/JSON file')
    parser.add_argument('--working-dir', default='deploy_workdir', help='Directory for generated Terraform files')
    args = parser.parse_args()

    config = read_config(args.config)

    provider = config.get('cloud_provider')
    if provider not in ('aws', 'gcp', 'azure'):
        print('cloud_provider must be one of aws, gcp or azure', file=sys.stderr)
        sys.exit(1)

    # Build tfvars dictionary
    tfvars = build_tfvars(config, provider)

    # Prepare working directory
    os.makedirs(args.working_dir, exist_ok=True)
    provider_src = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'terraform', provider)
    provider_dst = os.path.join(args.working_dir, provider)
    if not os.path.isdir(provider_dst):
        subprocess.run(['cp', '-r', provider_src, provider_dst], check=True)

    # Write tfvars file
    tfvars_path = write_tfvars_file(tfvars, provider_dst)
    print(f"[DPE] Generated Terraform variables file at {tfvars_path}")

    # Run Terraform
    tf_dir = provider_dst
    run_cmd(['terraform', 'init', '-input=false'], cwd=tf_dir)
    run_cmd(['terraform', 'plan', '-input=false'], cwd=tf_dir)
    run_cmd(['terraform', 'apply', '-auto-approve', '-input=false'], cwd=tf_dir)

    # Capture outputs
    try:
        output_json = subprocess.check_output(['terraform', 'output', '-json'], cwd=tf_dir)
        outputs = json.loads(output_json)
    except Exception:
        outputs = {}

    # Determine configuration management tool
    config_tool = config.get('configuration_management', 'ansible').lower()
    if config_tool == 'ansible':
        print("[DPE] Running Ansible playbook...")
        inventory_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'ansible', 'inventory.ini')
        playbook_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'ansible', 'playbook.yml')
        run_cmd(['ansible-playbook', '-i', inventory_path, playbook_path])
    elif config_tool == 'puppet':
        print("[DPE] Applying Puppet manifests...")
        site_pp = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'puppet', 'manifests', 'site.pp')
        run_cmd(['puppet', 'apply', site_pp])
    elif config_tool in ('scripts', 'shell', 'bash'):
        print("[DPE] Executing fallback shell scripts for installation...")
        base_scripts = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'scripts')
        if tfvars.get('enable_kafka'):
            run_cmd([os.path.join(base_scripts, 'install_kafka.sh')])
        if tfvars.get('enable_rdbms'):
            run_cmd([os.path.join(base_scripts, 'install_rdbms.sh')])
        if tfvars.get('enable_elasticsearch'):
            run_cmd([os.path.join(base_scripts, 'install_elasticsearch.sh')])
        if tfvars.get('enable_spark'):
            run_cmd([os.path.join(base_scripts, 'install_spark.sh')])
        # Always install observability collector and backend
        obs_env = os.environ.copy()
        obs_env['BACKEND'] = tfvars.get('observability_backend', 'grafana')
        run_cmd([os.path.join(base_scripts, 'install_observability.sh')], cwd=None)
    else:
        print(f"Unsupported configuration_management: {config_tool}", file=sys.stderr)
        sys.exit(1)

    print("[DPE] Deployment complete. Outputs:")
    print(json.dumps(outputs, indent=2))


if __name__ == '__main__':
    main()