# ==========================================
# TERRAFORM SERVICE ACCOUNT IAM ROLES
# ==========================================

resource "google_project_iam_member" "terraform_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${var.terraform_sa_email}"
}

resource "google_project_iam_member" "terraform_iam_admin" {
  project = var.project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${var.terraform_sa_email}"
}

resource "google_project_iam_member" "terraform_security_admin" {
  project = var.project_id
  role    = "roles/iam.securityAdmin"
  member  = "serviceAccount:${var.terraform_sa_email}"
}

# ==========================================
# BUILD SERVICE ACCOUNT IAM ROLES
# ==========================================

resource "google_project_iam_member" "build_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${var.build_sa_email}"
}

resource "google_project_iam_member" "build_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${var.build_sa_email}"
}

resource "google_project_iam_member" "build_logs_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${var.build_sa_email}"
}

resource "google_project_iam_member" "build_sa_user" {
  for_each = var.runtime_sa_emails

  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${var.build_sa_email}"

  condition {
    title       = "Allow impersonation of ${each.key} runtime SA"
    description = "Build SA can impersonate this runtime SA for deployment"
    expression  = "resource.name == 'projects/${var.project_id}/serviceAccounts/${each.value}'"
  }
}

# ==========================================
# RUNTIME SERVICE ACCOUNT IAM ROLES
# ==========================================

resource "google_project_iam_member" "runtime_logs_writer" {
  for_each = var.runtime_sa_emails

  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${each.value}"
}

resource "google_project_iam_member" "runtime_metrics_writer" {
  for_each = var.runtime_sa_emails

  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${each.value}"
}

resource "google_project_iam_member" "runtime_sql_client" {
  for_each = var.runtime_sa_emails

  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${each.value}"
}

resource "google_project_iam_member" "runtime_secret_accessor" {
  for_each = var.runtime_sa_emails

  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${each.value}"
}

resource "google_project_iam_member" "runtime_vpc_user" {
  for_each = var.runtime_sa_emails

  project = var.project_id
  role    = "roles/vpcaccess.user"
  member  = "serviceAccount:${each.value}"
}
