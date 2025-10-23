# Allow internal cluster communication
resource "google_compute_firewall" "allow_internal" {
  name        = "${var.vpc_name}-allow-internal"
  description = "Allow all internal traffic between GKE nodes, pods, and services"
  network     = var.network
  project     = var.project_id
  priority    = 1000

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [
    var.subnet_cidr,
    var.pods_cidr,
    var.services_cidr,
  ]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow GKE master to communicate with nodes
resource "google_compute_firewall" "allow_master_to_nodes" {
  name        = "${var.vpc_name}-allow-master-to-nodes"
  description = "Allow GKE control plane to communicate with worker nodes"
  network     = var.network
  project     = var.project_id
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["443", "10250", "8443", "9443"]
  }

  source_ranges = [var.master_cidr]
  target_tags   = ["gke-node"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow Google Cloud health checks and load balancers
resource "google_compute_firewall" "allow_health_checks" {
  name        = "${var.vpc_name}-allow-health-checks"
  description = "Allow Google Cloud health checks and load balancers"
  network     = var.network
  project     = var.project_id
  priority    = 1000

  allow {
    protocol = "tcp"
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]

  target_tags = ["gke-node"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow SSH via Identity-Aware Proxy (optional - only if needed)
resource "google_compute_firewall" "allow_iap_ssh" {
  count       = var.enable_ssh ? 1 : 0
  name        = "${var.vpc_name}-allow-iap-ssh"
  description = "Allow SSH access via Identity-Aware Proxy"
  network     = var.network
  project     = var.project_id
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["gke-node"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Explicit deny all as fallback (best practice)
resource "google_compute_firewall" "deny_all" {
  name        = "${var.vpc_name}-deny-all"
  description = "Deny all traffic not explicitly allowed"
  network     = var.network
  project     = var.project_id
  priority    = 65534 # Lowest priority - evaluated last

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
