output "service_url" {
  description = "Cloud Run service URL"
  value       = module.service.service_url
}

output "service_name" {
  description = "Cloud Run service name"
  value       = module.service.service_name
}

output "database_instance_name" {
  description = "Cloud SQL instance name"
  value       = module.database.instance_name
}

output "database_connection_name" {
  description = "Cloud SQL connection name"
  value       = module.database.instance_connection_name
}

output "database_ip_address" {
  description = "Database public IP address"
  value       = module.database.instance_ip_address
}

output "database_private_ip_address" {
  description = "Database private IP address"
  value       = module.database.instance_private_ip_address
}

output "database_password_secret_id" {
  description = "Secret ID for database password"
  value       = module.db_password_secret.secret_id
}

output "database_password" {
  description = "Database password"
  value       = random_password.db_password.result
  sensitive   = true
}
