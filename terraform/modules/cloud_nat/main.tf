# Cloud Router (required for Cloud NAT)
resource "google_compute_router" "router" {
  name    = var.router_name
  region  = var.region
  network = var.network
  project = var.project_id

  bgp {
    asn = 64514
  }
}

# Cloud NAT for private GKE nodes to access internet
resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  router                             = google_compute_router.router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat

  # Logging configuration
  log_config {
    enable = var.enable_logging
    filter = var.log_filter
  }

  # Minimum ports per VM
  min_ports_per_vm = var.min_ports_per_vm

  # Enable Dynamic Port Allocation
  enable_dynamic_port_allocation      = var.enable_dynamic_port_allocation
  enable_endpoint_independent_mapping = var.enable_endpoint_independent_mapping
}
