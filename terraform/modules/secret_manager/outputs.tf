output "secret_id" {
  description = "The ID of the created secret"
  value       = google_secret_manager_secret.secret.secret_id
}

output "secret_name" {
  description = "The full resource name of the secret"
  value       = google_secret_manager_secret.secret.name
}

output "secret_version" {
  description = "The version of the secret"
  value       = google_secret_manager_secret_version.secret_version.version
}
