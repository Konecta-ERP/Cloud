variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "vpc_name" {
  description = "Name prefix for firewall rules"
  type        = string
}

variable "network" {
  description = "VPC network self link"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for node subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "pods_cidr" {
  description = "CIDR range for pods"
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_cidr" {
  description = "CIDR range for services"
  type        = string
  default     = "10.2.0.0/16"
}

variable "master_cidr" {
  description = "CIDR range for GKE master"
  type        = string
  default     = "172.16.0.0/28"
}

variable "enable_ssh" {
  description = "Enable SSH access via IAP for debugging"
  type        = bool
  default     = false
}
