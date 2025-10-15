# Random password for database
resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store database password in Secret Manager
module "db_password_secret" {
  source = "../secret_manager"

  project_id  = var.project_id
  secret_id   = "${var.service_name}-db-password"
  secret_data = random_password.db_password.result

  labels = {
    environment = var.environment
    service     = var.service_name
  }
}

# Grant service account access to the secret
resource "google_secret_manager_secret_iam_member" "db_password_access" {
  secret_id = module.db_password_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.service_account_email}"
}

# Cloud SQL Database
module "database" {
  source = "../cloud_sql"

  project_id    = var.project_id
  region        = var.region
  instance_name = "${var.service_name}-db-${var.environment}"

  database_name    = var.database_name
  db_user_name     = var.db_user_name
  db_user_password = random_password.db_password.result

  database_version               = var.database_version
  tier                           = var.database_tier
  disk_size                      = var.database_disk_size
  disk_type                      = var.database_disk_type
  deletion_protection            = var.deletion_protection
  backup_enabled                 = var.backup_enabled
  point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
  public_ip_enabled              = var.public_ip_enabled
  authorized_networks            = var.public_ip_enabled ? var.authorized_networks : []
  
  # Private network configuration
  private_network_id         = var.private_network_id
  private_network_dependency = var.private_network_dependency
}

# Cloud Run Service
module "service" {
  source = "../cloud_run_service"

  project_id            = var.project_id
  region                = var.region
  service_name          = var.service_name
  container_image       = var.container_image
  service_account_email = var.service_account_email

  min_instances  = var.min_instances
  max_instances  = var.max_instances
  cpu_limit      = var.cpu_limit
  memory_limit   = var.memory_limit
  container_port = var.container_port

  # VPC Connector configuration
  vpc_connector_id   = var.vpc_connector_id
  vpc_egress_setting = var.vpc_egress_setting

  environment_variables = merge(
    {
      ENVIRONMENT = var.environment
      DB_HOST     = var.public_ip_enabled ? module.database.instance_ip_address : module.database.instance_private_ip_address
      DB_PORT     = "5432"
      DB_NAME     = var.database_name
      DB_USER     = var.db_user_name
    },
    var.additional_env_vars
  )

  secret_environment_variables = {
    DB_PASSWORD = {
      secret_name = module.db_password_secret.secret_id
      version     = "latest"
    }
  }

  cloud_sql_instances   = var.cloud_sql_instances
  allow_unauthenticated = var.allow_unauthenticated

  labels = {
    environment = var.environment
    service     = var.service_name
  }
}
