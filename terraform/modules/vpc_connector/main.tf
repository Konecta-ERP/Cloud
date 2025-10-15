resource "google_vpc_access_connector" "connector" {
  name          = var.connector_name
  region        = var.region
  network       = var.vpc_name
  ip_cidr_range = var.connector_cidr
  project       = var.project_id

  machine_type  = var.machine_type
  min_instances = var.min_instances
  max_instances = var.max_instances
}
