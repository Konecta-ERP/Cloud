output "instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = google_sql_database_instance.main.name
}

output "instance_connection_name" {
  description = "The connection name for the Cloud SQL instance"
  value       = google_sql_database_instance.main.connection_name
}

output "instance_ip_address" {
  description = "The public IP address of the Cloud SQL instance"
  value       = length(google_sql_database_instance.main.ip_address) > 0 ? google_sql_database_instance.main.ip_address[0].ip_address : null
}

output "instance_private_ip_address" {
  description = "The private IP address of the Cloud SQL instance"
  value       = try(google_sql_database_instance.main.private_ip_address, null)
}

output "database_name" {
  description = "The name of the database"
  value       = google_sql_database.database.name
}

output "db_user_name" {
  description = "The database user name"
  value       = google_sql_user.user.name
}
