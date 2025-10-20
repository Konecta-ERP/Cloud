variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "network" {
  description = "VPC network name or self-link"
  type        = string
}

variable "router_name" {
  description = "Name of the Cloud Router"
  type        = string
}

variable "nat_name" {
  description = "Name of the Cloud NAT"
  type        = string
}

variable "nat_ip_allocate_option" {
  description = "How external IPs should be allocated (AUTO_ONLY or MANUAL_ONLY)"
  type        = string
  default     = "AUTO_ONLY"
}

variable "source_subnetwork_ip_ranges_to_nat" {
  description = "How NAT should be configured per subnetwork"
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "enable_logging" {
  description = "Enable logging for NAT"
  type        = bool
  default     = false
}

variable "log_filter" {
  description = "Log filter (ERRORS_ONLY, TRANSLATIONS_ONLY, ALL)"
  type        = string
  default     = "ERRORS_ONLY"
}

variable "min_ports_per_vm" {
  description = "Minimum number of ports per VM"
  type        = number
  default     = 64
}

variable "enable_dynamic_port_allocation" {
  description = "Enable dynamic port allocation"
  type        = bool
  default     = false
}

variable "enable_endpoint_independent_mapping" {
  description = "Enable endpoint independent mapping"
  type        = bool
  default     = true
}
