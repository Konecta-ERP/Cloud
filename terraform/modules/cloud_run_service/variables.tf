# Required variables
variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy the Cloud Run service"
  type        = string
}

variable "service_name" {
  description = "The name of the Cloud Run service"
  type        = string
}

variable "container_image" {
  description = "The container image to deploy"
  type        = string
}

variable "service_account_email" {
  description = "The service account email for the Cloud Run service"
  type        = string
}

# Container configuration
variable "container_command" {
  description = "Override container entrypoint command"
  type        = list(string)
  default     = null
}

variable "container_args" {
  description = "Override container arguments"
  type        = list(string)
  default     = null
}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
  default     = 8080
}

# Resource configuration
variable "cpu_limit" {
  description = "CPU limit (e.g., '1', '2', '4')"
  type        = string
  default     = "1"
}

variable "memory_limit" {
  description = "Memory limit (e.g., '512Mi', '1Gi', '2Gi')"
  type        = string
  default     = "512Mi"
}

variable "cpu_idle" {
  description = "CPU is allocated only during request processing"
  type        = bool
  default     = true
}

variable "startup_cpu_boost" {
  description = "Enable startup CPU boost"
  type        = bool
  default     = false
}

# Scaling configuration
variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

# Network configuration
variable "ingress" {
  description = "Ingress settings (INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY, INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER)"
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"
}

variable "vpc_connector_id" {
  description = "VPC connector ID for private network access"
  type        = string
  default     = null
}

variable "vpc_egress_setting" {
  description = "VPC egress setting (ALL_TRAFFIC or PRIVATE_RANGES_ONLY)"
  type        = string
  default     = "PRIVATE_RANGES_ONLY"
}

# Environment variables
variable "environment_variables" {
  description = "Environment variables as key-value pairs"
  type        = map(string)
  default     = {}
}

variable "secret_environment_variables" {
  description = "Secret environment variables from Secret Manager"
  type = map(object({
    secret_name = string
    version     = string
  }))
  default = {}
}

# Cloud SQL configuration
variable "cloud_sql_instances" {
  description = "List of Cloud SQL instance connection names"
  type        = list(string)
  default     = null
}

# Security
variable "allow_unauthenticated" {
  description = "Allow unauthenticated access to the service"
  type        = bool
  default     = false
}

# Labels
variable "labels" {
  description = "Labels to apply to the service"
  type        = map(string)
  default     = {}
}
