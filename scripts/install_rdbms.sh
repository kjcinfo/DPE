#!/usr/bin/env bash
# install_rdbms.sh
#
# Example shell script to install a relational database server (PostgreSQL
# by default) on a Linux host.  Use this script as a fallback when
# configuration management tools are not available.  It installs the
# selected database engine, sets up a basic configuration and starts the
# service.  Adjust variables, security settings and data directory as
# required for your environment.

set -euo pipefail

DB_ENGINE=${DB_ENGINE:-postgresql}

echo "[DPE] Installing RDBMS: ${DB_ENGINE}..."

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  case "$DB_ENGINE" in
    postgresql)
      sudo DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql
      ;;
    mysql)
      sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
      ;;
    *)
      echo "Unsupported DB_ENGINE: $DB_ENGINE" >&2
      exit 1
      ;;
  esac
elif command -v yum >/dev/null 2>&1; then
  case "$DB_ENGINE" in
    postgresql)
      sudo yum install -y postgresql-server
      sudo postgresql-setup initdb
      ;;
    mysql)
      sudo yum install -y mysql-server
      ;;
    *)
      echo "Unsupported DB_ENGINE: $DB_ENGINE" >&2
      exit 1
      ;;
  esac
else
  echo "Unsupported package manager. Please install the database manually." >&2
  exit 1
fi

echo "[DPE] RDBMS installation complete."
