output "repository_id" {
  description = "The ID of the created Artifact Registry repository"
  value       = google_artifact_registry_repository.main.repository_id
}

output "repository_name" {
  description = "The full name of the repository"
  value       = google_artifact_registry_repository.main.name
}

output "repository_url" {
  description = "The repository URL for docker push/pull"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}"
}
