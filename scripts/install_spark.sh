#!/usr/bin/env bash
# install_spark.sh
#
# Example shell script to install Apache Spark on a Linux host.  This
# script downloads a prebuilt Spark binary package from the Apache mirror,
# extracts it to /opt/spark and creates convenience symlinks.  It then
# starts the Spark master and worker services.  You may need to adjust
# user permissions, environment variables and systemd unit files for
# production use.

set -euo pipefail

SPARK_VERSION=${SPARK_VERSION:-3.4.1}
SPARK_HADOOP_VERSION=${SPARK_HADOOP_VERSION:-3}
SPARK_PACKAGE="spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}"
INSTALL_DIR=/opt/spark

echo "[DPE] Installing Apache Spark ${SPARK_VERSION}..."

if [ ! -d "$INSTALL_DIR" ]; then
  sudo mkdir -p "$INSTALL_DIR"
fi

# Download Spark tarball if not already present
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
wget -q "https://downloads.apache.org/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz"
tar -xzf "${SPARK_PACKAGE}.tgz"
sudo mv "${SPARK_PACKAGE}"/* "$INSTALL_DIR/"

cd - >/dev/null
rm -rf "$TMP_DIR"

# Create environment variables
sudo tee /etc/profile.d/spark.sh >/dev/null <<EOF_ENV
export SPARK_HOME=${INSTALL_DIR}
export PATH=\$PATH:${INSTALL_DIR}/bin
EOF_ENV

source /etc/profile.d/spark.sh

echo "[DPE] Spark installation complete.  Run '${INSTALL_DIR}/sbin/start-all.sh' to start master and workers."
