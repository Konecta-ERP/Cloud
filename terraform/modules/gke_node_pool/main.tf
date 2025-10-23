# GKE Node Pool with Autoscaling
resource "google_container_node_pool" "primary" {
  name       = var.node_pool_name
  location   = var.location
  cluster    = var.cluster_name
  project    = var.project_id
  node_count = var.initial_node_count

  # Autoscaling configuration
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  # Management configuration
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Node configuration
  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type
    preemptible  = var.preemptible

    # Service account for nodes
    service_account = var.service_account

    # OAuth scopes
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    # Node labels
    labels = merge(
      var.labels,
      {
        node_pool = var.node_pool_name
      }
    )

    # Node Taints for scheduling specific workloads
    dynamic "taint" {
      for_each = var.node_taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    # Node metadata
    metadata = {
      disable-legacy-endpoints = "true"
    }

    # Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Shielded instance config
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # Tags for network policies
    tags = var.tags
  }

  # Upgrade settings
  upgrade_settings {
    max_surge       = var.max_surge
    max_unavailable = var.max_unavailable
  }
}
