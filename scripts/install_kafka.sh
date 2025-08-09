#!/usr/bin/env bash
# install_kafka.sh
#
# Example shell script to install Apache Kafka on a Linux host.  This script
# is intended as a fallback configuration mechanism when neither Ansible nor
# Puppet is available.  It attempts to detect the package manager (apt or
# yum) and installs Kafka from the distribution packages.  Adjust the
# commands according to your operating system and security requirements.

set -euo pipefail

echo "[DPE] Installing Kafka..."

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y kafka
elif command -v yum >/dev/null 2>&1; then
  sudo yum install -y kafka
else
  echo "Unsupported package manager. Please install Kafka manually." >&2
  exit 1
fi

echo "[DPE] Kafka installation complete."
