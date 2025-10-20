resource "google_sql_database_instance" "main" {
  name             = var.instance_name
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_size         = var.disk_size
    disk_type         = var.disk_type

    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = var.backup_start_time
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
      transaction_log_retention_days = var.transaction_log_retention_days

      backup_retention_settings {
        retained_backups = var.retained_backups
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled    = var.public_ip_enabled
      private_network = var.private_network_id

      enable_private_path_for_google_cloud_services = var.private_network_id != null ? true : false

      ssl_mode = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"

      dynamic "authorized_networks" {
        for_each = var.public_ip_enabled ? var.authorized_networks : []
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.value
        }
      }
    }

    database_flags {
      name  = "max_connections"
      value = var.max_connections
    }
  }

  # Add dependency for private network connection
  depends_on = [var.private_network_dependency]
}

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

resource "google_sql_user" "user" {
  name     = var.db_user_name
  instance = google_sql_database_instance.main.name
  password = var.db_user_password
  project  = var.project_id
}
