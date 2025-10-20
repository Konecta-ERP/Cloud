variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Location for the cluster (region for regional cluster, zone for zonal)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "network" {
  description = "VPC network name or self-link"
  type        = string
}

variable "subnetwork" {
  description = "VPC subnetwork name or self-link"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the Kubernetes master (must be /28)"
  type        = string
  default     = "172.16.0.0/28"
}

variable "pods_secondary_range_name" {
  description = "Name of the secondary range for pods"
  type        = string
  default     = "pods"
}

variable "services_secondary_range_name" {
  description = "Name of the secondary range for services"
  type        = string
  default     = "services"
}

variable "master_authorized_networks" {
  description = "List of CIDR blocks that can access the Kubernetes master"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "maintenance_start_time" {
  description = "Start time for maintenance window (HH:MM format, UTC)"
  type        = string
  default     = "03:00"
}

variable "release_channel" {
  description = "Release channel (RAPID, REGULAR, STABLE)"
  type        = string
  default     = "REGULAR"
}

variable "labels" {
  description = "Labels to apply to the cluster"
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "network_dependency" {
  description = "Dependency to ensure network is created first"
  type        = any
  default     = null
}

variable "cluster_autoscaling_profile" {
  description = "The autoscaling profile for the cluster (BALANCED, OPTIMIZE_UTILIZATION, COMPACT)"
  type        = string
  default     = "BALANCED" # Default to BALANCED for safety, will override in envs/dev
}

variable "min_master_version" {
  description = "The minimum GKE master version. If not specified, GKE will manage it via release channel."
  type        = string
  default     = null # Let release channel manage by default
}
