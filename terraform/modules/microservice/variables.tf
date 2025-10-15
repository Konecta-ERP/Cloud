variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "service_name" {
  description = "Name of the microservice"
  type        = string
}

variable "service_account_email" {
  description = "Service account email for the microservice"
  type        = string
}

variable "container_image" {
  description = "Docker container image"
  type        = string
  default     = "gcr.io/cloudrun/hello"
}

# Database variables
variable "database_name" {
  description = "Database name"
  type        = string
}

variable "db_user_name" {
  description = "Database user name"
  type        = string
}

variable "database_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "POSTGRES_15"
}

variable "database_tier" {
  description = "Database tier"
  type        = string
  default     = "db-f1-micro"
}

variable "database_disk_size" {
  description = "Database disk size in GB"
  type        = number
  default     = 10
}

variable "database_disk_type" {
  description = "Database disk type"
  type        = string
  default     = "PD_HDD"
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "backup_enabled" {
  description = "Enable backups"
  type        = bool
  default     = true
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = false
}

variable "public_ip_enabled" {
  description = "Enable public IP"
  type        = bool
  default     = false  
}

variable "authorized_networks" {
  description = "Authorized networks for database access"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# Cloud Run variables
variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 3
}

variable "cpu_limit" {
  description = "CPU limit"
  type        = string
  default     = "1"
}

variable "memory_limit" {
  description = "Memory limit"
  type        = string
  default     = "512Mi"
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8080
}

variable "cloud_sql_instances" {
  description = "Cloud SQL instances to connect"
  type        = list(string)
  default     = null
}

variable "allow_unauthenticated" {
  description = "Allow unauthenticated access"
  type        = bool
  default     = true
}

variable "additional_env_vars" {
  description = "Additional environment variables"
  type        = map(string)
  default     = {}
}
variable "vpc_connector_id" {
  description = "VPC connector ID"
  type        = string
  default     = null
}

variable "vpc_egress_setting" {
  description = "VPC egress setting"
  type        = string
  default     = "PRIVATE_RANGES_ONLY"
}

variable "private_network_id" {
  description = "VPC network ID for private IP"
  type        = string
  default     = null
}

variable "private_network_dependency" {
  description = "Dependency for private services access"
  type        = any
  default     = null
}
