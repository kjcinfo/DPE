#!/usr/bin/env bash
# install_observability.sh
#
# Example shell script to install observability components on a Linux host.
# This script deploys the OpenTelemetry collector and optionally a backend
# such as Grafana, OpenSearch or Elasticsearch.  Use the BACKEND
# environment variable to select a backend (grafana|opensearch|elasticsearch).
#
# NOTE: These installation steps are simplified for demonstration.  You
# should harden the configuration, enable authentication and adapt the
# collector configuration to your own environment.

set -euo pipefail

BACKEND=${BACKEND:-grafana}

echo "[DPE] Installing OpenTelemetry collector..."

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y otel-collector
elif command -v yum >/dev/null 2>&1; then
  sudo yum install -y otel-collector
else
  echo "Unsupported package manager. Please install the OpenTelemetry collector manually." >&2
  exit 1
fi

echo "[DPE] Installing observability backend: $BACKEND..."

case "$BACKEND" in
  grafana)
    # Install Grafana
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get install -y software-properties-common wget apt-transport-https
      wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
      sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
      sudo apt-get update && sudo apt-get install -y grafana
      sudo systemctl enable grafana-server && sudo systemctl start grafana-server
    elif command -v yum >/dev/null 2>&1; then
      sudo yum install -y grafana
      sudo systemctl enable grafana-server && sudo systemctl start grafana-server
    fi
    ;;
  opensearch)
    # Install OpenSearch
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get install -y wget apt-transport-https gnupg
      wget -qO - https://artifacts.opensearch.org/publickeys/opensearch.pgp | sudo apt-key add -
      echo "deb https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/apt stable main" | sudo tee /etc/apt/sources.list.d/opensearch-2.x.list
      sudo apt-get update && sudo apt-get install -y opensearch
      sudo systemctl enable opensearch.service && sudo systemctl start opensearch.service
    elif command -v yum >/dev/null 2>&1; then
      sudo yum install -y opensearch
      sudo systemctl enable opensearch.service && sudo systemctl start opensearch.service
    fi
    ;;
  elasticsearch)
    # Install Elasticsearch
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get install -y wget apt-transport-https
      wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
      echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
      sudo apt-get update && sudo apt-get install -y elasticsearch
      sudo systemctl enable elasticsearch.service && sudo systemctl start elasticsearch.service
    elif command -v yum >/dev/null 2>&1; then
      sudo yum install -y elasticsearch
      sudo systemctl enable elasticsearch.service && sudo systemctl start elasticsearch.service
    fi
    ;;
  *)
    echo "Unsupported BACKEND: $BACKEND" >&2
    exit 1
    ;;
esac

echo "[DPE] Observability components installed."
