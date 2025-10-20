output "terraform_sa_roles" {
  description = "Roles granted to Terraform service account"
  value = [
    "roles/editor",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.securityAdmin"
  ]
}

output "build_sa_roles" {
  description = "Roles granted to Build service account"
  value = [
    "roles/artifactregistry.writer",
    "roles/run.developer",
    "roles/logging.logWriter",
    "roles/iam.serviceAccountUser"
  ]
}

output "runtime_sa_roles" {
  description = "Roles granted to Runtime service accounts"
  value = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor",
    "roles/vpcaccess.user"
  ]
}
