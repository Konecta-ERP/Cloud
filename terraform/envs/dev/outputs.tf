# ============================================================================
# PROJECT & INFRASTRUCTURE
# ============================================================================

output "enabled_apis" {
  description = "List of enabled Google Cloud APIs"
  value       = module.project_services.enabled_services
}

output "vpc_id" {
  description = "VPC network ID"
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "VPC network name"
  value       = module.vpc.vpc_name
}

output "vpc_connector_id" {
  description = "VPC connector ID"
  value       = module.vpc_connector.connector_id
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  value       = module.artifact_registry.repository_url
}

# ============================================================================
# SERVICE ACCOUNTS
# ============================================================================

output "terraform_service_account" {
  description = "Terraform service account email"
  value       = module.service_accounts.terraform_sa_email
}

output "build_service_account" {
  description = "CI/CD build service account email"
  value       = module.service_accounts.build_sa_email
}

output "runtime_service_accounts" {
  description = "Runtime service account emails per microservice"
  value       = module.service_accounts.runtime_sa_emails
}

# ============================================================================
# IAM
# ============================================================================

output "iam_roles_summary" {
  description = "Summary of IAM roles granted"
  value = {
    terraform_sa = module.iam.terraform_sa_roles
    build_sa     = module.iam.build_sa_roles
    runtime_sa   = module.iam.runtime_sa_roles
  }
}

# ============================================================================
# KEYCLOAK
# ============================================================================

output "keycloak_url" {
  description = "Keycloak service URL"
  value       = module.keycloak.service_url
}

output "keycloak_db_instance_connection_name" {
  description = "Keycloak Cloud SQL instance connection name"
  value       = module.keycloak_db.instance_connection_name
}

output "keycloak_db_private_ip" {
  description = "Keycloak Cloud SQL instance private IP"
  value       = module.keycloak_db.instance_private_ip_address
}

output "keycloak_db_password_secret" {
  description = "Secret Manager secret name for Keycloak database password"
  value       = module.keycloak_db_password.secret_name
}

output "keycloak_db_password" {
  description = "Keycloak database password (retrieve with: terraform output -raw keycloak_db_password)"
  value       = random_password.keycloak_db_password.result
  sensitive   = true
}

output "gke_cluster_name" {
  description = "GKE cluster name for kubectl config"
  value       = module.gke_cluster.cluster_name
}

output "gke_cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke_cluster.cluster_endpoint
  sensitive   = true
}
