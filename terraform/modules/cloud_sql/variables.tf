# Required variables
variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "The region for the Cloud SQL instance"
  type        = string
}

variable "instance_name" {
  description = "The name of the Cloud SQL instance"
  type        = string
}

variable "database_name" {
  description = "The name of the database to create"
  type        = string
}

variable "db_user_name" {
  description = "The database user name"
  type        = string
}

variable "db_user_password" {
  description = "The database user password"
  type        = string
  sensitive   = true
}

# Instance configuration
variable "database_version" {
  description = "The database version (e.g., POSTGRES_15)"
  type        = string
  default     = "POSTGRES_15"
}

variable "tier" {
  description = "The machine tier (e.g., db-f1-micro, db-g1-small)"
  type        = string
  default     = "db-f1-micro"
}

variable "availability_type" {
  description = "Availability type (ZONAL or REGIONAL)"
  type        = string
  default     = "ZONAL"
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "Disk type (PD_SSD or PD_HDD)"
  type        = string
  default     = "PD_HDD"
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

# Backup configuration
variable "backup_enabled" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_start_time" {
  description = "Backup start time in HH:MM format (UTC)"
  type        = string
  default     = "03:00"
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = false
}

variable "transaction_log_retention_days" {
  description = "Number of days to retain transaction logs"
  type        = number
  default     = 7
}

variable "retained_backups" {
  description = "Number of backups to retain"
  type        = number
  default     = 7
}

# Network configuration
variable "public_ip_enabled" {
  description = "Enable public IP address"
  type        = bool
  default     = false
}

variable "private_network_id" {
  description = "VPC network ID for private IP (required if public_ip_enabled is false)"
  type        = string
  default     = null
}

variable "private_network_dependency" {
  description = "Dependency to ensure private services access is ready"
  type        = any
  default     = null
}

variable "authorized_networks" {
  description = "List of authorized networks for Cloud SQL access (only used if public_ip_enabled is true)"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# Database configuration
variable "max_connections" {
  description = "Maximum number of connections"
  type        = string
  default     = "100"
}


