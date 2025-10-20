variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "connector_name" {
  description = "Name of the VPC connector"
  type        = string
}

variable "vpc_name" {
  description = "VPC network name"
  type        = string
}

variable "connector_cidr" {
  description = "CIDR range for the connector (must be /28)"
  type        = string
  default     = "10.8.0.0/28"
}

variable "machine_type" {
  description = "Machine type for connector instances"
  type        = string
  default     = "e2-micro"
}

variable "min_instances" {
  description = "Minimum number of connector instances"
  type        = number
  default     = 2
}

variable "max_instances" {
  description = "Maximum number of connector instances"
  type        = number
  default     = 3
}
