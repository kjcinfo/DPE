/*
 * Observability backend resources for GCP
 *
 * This file provisions a single Compute Engine VM to host the chosen
 * observability backend.  The type of backend (Grafana, OpenSearch or
 * Elasticsearch) is selected via the `observability_backend` variable in
 * variables.tf.  Each backend uses a simple startup script to install
 * the appropriate software.  You should customise these startup scripts
 * and VM sizes according to your operational needs.  By default all
 * backends use an e2-standard-2 instance with a 50 GB boot disk.
 */

resource "google_compute_instance" "observability_grafana" {
  count = var.observability_backend == "grafana" ? 1 : 0
  name  = var.observability_vm_name
  machine_type = var.observability_machine_type
  zone  = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20231212"
      size  = var.observability_disk_size
    }
  }

  network_interface {
    network       = var.network
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e
    # Install Grafana from the official repository
    apt-get update
    apt-get install -y software-properties-common wget apt-transport-https
    wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
    add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
    apt-get update && apt-get install -y grafana
    systemctl enable grafana-server
    systemctl start grafana-server
  EOF
}

resource "google_compute_instance" "observability_opensearch" {
  count = var.observability_backend == "opensearch" ? 1 : 0
  name  = var.observability_vm_name
  machine_type = var.observability_machine_type
  zone  = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20231212"
      size  = var.observability_disk_size
    }
  }

  network_interface {
    network       = var.network
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e
    # Install OpenSearch from the official repository
    apt-get update
    apt-get install -y wget apt-transport-https gnupg
    wget -qO - https://artifacts.opensearch.org/publickeys/opensearch.pgp | apt-key add -
    echo "deb https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/apt stable main" | tee /etc/apt/sources.list.d/opensearch-2.x.list
    apt-get update && apt-get install -y opensearch
    systemctl enable opensearch.service
    systemctl start opensearch.service
  EOF
}

resource "google_compute_instance" "observability_elasticsearch" {
  count = var.observability_backend == "elasticsearch" ? 1 : 0
  name  = var.observability_vm_name
  machine_type = var.observability_machine_type
  zone  = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20231212"
      size  = var.observability_disk_size
    }
  }

  network_interface {
    network       = var.network
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e
    # Install Elasticsearch similar to the standalone VM.  This uses the
    # official Elastic packages.  Adjust the version as required.
    apt-get update
    apt-get install -y openjdk-11-jdk wget apt-transport-https
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
    echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-8.x.list
    apt-get update && apt-get install -y elasticsearch
    systemctl enable elasticsearch.service
    systemctl start elasticsearch.service
  EOF
}