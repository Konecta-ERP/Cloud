variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "Location for the node pool (same as cluster)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "node_pool_name" {
  description = "Name of the node pool"
  type        = string
}

variable "initial_node_count" {
  description = "Initial number of nodes per zone"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Minimum number of nodes per zone"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes per zone"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-medium"
}

variable "disk_size_gb" {
  description = "Disk size in GB for each node"
  type        = number
  default     = 50
}

variable "disk_type" {
  description = "Disk type (pd-standard or pd-ssd)"
  type        = string
  default     = "pd-standard"
}

variable "preemptible" {
  description = "Use preemptible nodes (cheaper but can be terminated)"
  type        = bool
  default     = false
}

variable "service_account" {
  description = "Service account for nodes"
  type        = string
}

variable "labels" {
  description = "Labels to apply to nodes"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Network tags for nodes"
  type        = list(string)
  default     = []
}

variable "max_surge" {
  description = "Maximum number of nodes created during an upgrade"
  type        = number
  default     = 1
}

variable "max_unavailable" {
  description = "Maximum number of nodes unavailable during an upgrade"
  type        = number
  default     = 0
}

variable "node_taints" {
  description = "List of taints to apply to the nodes in the node pool."
  type = list(object({
    key    = string
    value  = string
    effect = string # e.g., "NO_SCHEDULE", "PREFER_NO_SCHEDULE", "NO_EXECUTE"
  }))
  default = []
}
