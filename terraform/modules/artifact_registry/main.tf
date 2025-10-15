resource "google_artifact_registry_repository" "main" {
  location      = var.region
  repository_id = var.repository_id
  description   = var.description
  format        = "DOCKER"
  project       = var.project_id

  docker_config {
    immutable_tags = var.immutable_tags
  }
}
