resource "google_service_account" "terraform_sa" {
  account_id   = var.terraform_sa_name
  display_name = "Terraform Service Account"
  description  = "Service account for Terraform to manage infrastructure"
  project      = var.project_id
}

resource "google_service_account" "build_sa" {
  account_id   = var.build_sa_name
  display_name = "CI/CD Build Service Account"
  description  = "Service account for Cloud Build to push images and deploy to Cloud Run"
  project      = var.project_id
}

resource "google_service_account" "runtime_sa" {
  for_each = toset(var.service_names)

  account_id   = "${each.value}-runtime-sa"
  display_name = "Runtime SA for ${each.value}"
  description  = "Runtime service account for ${each.value} microservice"
  project      = var.project_id
}
