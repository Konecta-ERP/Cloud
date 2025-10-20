output "terraform_sa_email" {
  description = "Email of the Terraform service account"
  value       = google_service_account.terraform_sa.email
}

output "terraform_sa_id" {
  description = "ID of the Terraform service account"
  value       = google_service_account.terraform_sa.id
}

output "build_sa_email" {
  description = "Email of the CI/CD build service account"
  value       = google_service_account.build_sa.email
}

output "build_sa_id" {
  description = "ID of the CI/CD build service account"
  value       = google_service_account.build_sa.id
}

output "runtime_sa_emails" {
  description = "Map of service names to their runtime service account emails"
  value = {
    for k, v in google_service_account.runtime_sa : k => v.email
  }
}

output "runtime_sa_ids" {
  description = "Map of service names to their runtime service account IDs"
  value = {
    for k, v in google_service_account.runtime_sa : k => v.id
  }
}
