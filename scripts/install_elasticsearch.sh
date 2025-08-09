#!/usr/bin/env bash
# install_elasticsearch.sh
#
# Example shell script to install Elasticsearch on a Linux host.  This
# provides a simple fallback when configuration management tools are not
# available.  The script installs Elasticsearch from the official Elastic
# repository on Debian/Ubuntu or a compatible repository on RedHat/CentOS.
set -euo pipefail

echo "[DPE] Installing Elasticsearch..."

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y wget apt-transport-https
  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
  echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
  sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y elasticsearch
  sudo systemctl enable elasticsearch.service
  sudo systemctl start elasticsearch.service
elif command -v yum >/dev/null 2>&1; then
  sudo yum install -y wget
  sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
  cat <<EOF_REPO | sudo tee /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-8.x]
name=Elasticsearch repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF_REPO
  sudo yum install -y elasticsearch
  sudo systemctl enable elasticsearch.service
  sudo systemctl start elasticsearch.service
else
  echo "Unsupported package manager. Please install Elasticsearch manually." >&2
  exit 1
fi

echo "[DPE] Elasticsearch installation complete."
