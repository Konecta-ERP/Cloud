resource "google_secret_manager_secret" "secret" {
  secret_id = var.secret_id
  project   = var.project_id

  replication {
    auto {}
  }

  labels = var.labels
}

resource "google_secret_manager_secret_version" "secret_version" {
  secret      = google_secret_manager_secret.secret.id
  secret_data = var.secret_data
}
