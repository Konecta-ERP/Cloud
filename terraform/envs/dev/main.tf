provider "google" {
  project = var.project_id
  region  = var.region
}

# ============================================================================
# PROJECT SETUP
# ============================================================================

module "project_services" {
  source = "../../modules/project_services"

  project_id = var.project_id
}

# ============================================================================
# VPC NETWORK
# ============================================================================

module "vpc" {
  source = "../../modules/vpc"

  project_id  = var.project_id
  region      = var.region
  vpc_name    = "erp-vpc-dev"
  subnet_cidr = "10.0.0.0/24"

  depends_on = [module.project_services]
}

# ============================================================================
# VPC CONNECTOR
# ============================================================================

module "vpc_connector" {
  source = "../../modules/vpc_connector"

  project_id     = var.project_id
  region         = var.region
  connector_name = "erp-connector-dev"
  vpc_name       = module.vpc.vpc_name
  connector_cidr = "10.8.0.0/28"

  machine_type  = "e2-micro"
  min_instances = 2
  max_instances = 3

  depends_on = [module.vpc]
}

# ============================================================================
# ARTIFACT REGISTRY
# ============================================================================

module "artifact_registry" {
  source = "../../modules/artifact_registry"

  project_id    = var.project_id
  region        = var.region
  repository_id = "erp-services"
  description   = "Docker repository for ERP microservices in dev environment"

  depends_on = [module.project_services]
}

# ============================================================================
# SERVICE ACCOUNTS
# ============================================================================

module "service_accounts" {
  source = "../../modules/service_accounts"

  project_id        = var.project_id
  terraform_sa_name = "terraform-sa"
  build_sa_name     = "cicd-build-sa"
  service_names     = ["auth-service", "hr-service", "finance-service", "keycloak"]

  depends_on = [module.project_services]
}

# ============================================================================
# IAM
# ============================================================================

module "iam" {
  source = "../../modules/iam"

  project_id         = var.project_id
  terraform_sa_email = module.service_accounts.terraform_sa_email
  build_sa_email     = module.service_accounts.build_sa_email
  runtime_sa_emails  = module.service_accounts.runtime_sa_emails

  depends_on = [module.service_accounts]
}

# ============================================================================
# KEYCLOAK
# ============================================================================

resource "random_password" "keycloak_db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "keycloak_db_password" {
  source = "../../modules/secret_manager"

  project_id  = var.project_id
  secret_id   = "keycloak-db-password"
  secret_data = random_password.keycloak_db_password.result

  labels = {
    environment = "dev"
    service     = "keycloak"
  }

  depends_on = [module.project_services]
}

resource "google_secret_manager_secret_iam_member" "keycloak_db_password_access" {
  secret_id = module.keycloak_db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${module.service_accounts.runtime_sa_emails["keycloak"]}"

  depends_on = [module.keycloak_db_password, module.iam]
}

module "keycloak_db" {
  source = "../../modules/cloud_sql"

  project_id    = var.project_id
  region        = var.region
  instance_name = "keycloak-db-dev"

  database_name    = "keycloak"
  db_user_name     = "keycloak"
  db_user_password = random_password.keycloak_db_password.result

  database_version               = "POSTGRES_15"
  tier                           = "db-f1-micro"
  disk_size                      = 10
  disk_type                      = "PD_HDD"
  deletion_protection            = false
  backup_enabled                 = true
  point_in_time_recovery_enabled = false
  
  # PRIVATE IP CONFIGURATION
  public_ip_enabled          = false
  private_network_id         = module.vpc.vpc_id
  private_network_dependency = [module.vpc.private_vpc_connection]
  authorized_networks        = []

  depends_on = [module.project_services, module.vpc]
}

module "keycloak" {
  source = "../../modules/cloud_run_service"

  project_id            = var.project_id
  region                = var.region
  service_name          = "keycloak"
  container_image       = "docker.io/keycloak/keycloak:26.0"
  service_account_email = module.service_accounts.runtime_sa_emails["keycloak"]

  container_command = ["/opt/keycloak/bin/kc.sh"]
  container_args    = ["start-dev", "--db=postgres"]

  min_instances     = 0
  max_instances     = 3
  cpu_limit         = "2"
  memory_limit      = "2Gi"
  container_port    = 8080
  startup_cpu_boost = true

  # VPC CONNECTOR
  vpc_connector_id   = module.vpc_connector.connector_id
  vpc_egress_setting = "PRIVATE_RANGES_ONLY"

  environment_variables = {
    KC_DB_URL                      = "jdbc:postgresql://${module.keycloak_db.instance_private_ip_address}:5432/keycloak"
    KC_DB_USERNAME                 = "keycloak"
    KC_DB_SCHEMA                   = "public"
    KC_BOOTSTRAP_ADMIN_USERNAME    = "admin"
    KC_HTTP_ENABLED                = "true"
    KC_HOSTNAME_STRICT             = "false"
    KC_HOSTNAME_STRICT_BACKCHANNEL = "false"
    KC_PROXY_HEADERS               = "xforwarded"
  }

  secret_environment_variables = {
    KC_DB_PASSWORD = {
      secret_name = module.keycloak_db_password.secret_id
      version     = "latest"
    }
    KC_BOOTSTRAP_ADMIN_PASSWORD = {
      secret_name = module.keycloak_db_password.secret_id
      version     = "latest"
    }
  }

  cloud_sql_instances   = null
  allow_unauthenticated = true

  labels = {
    environment = "dev"
    service     = "keycloak"
  }

  depends_on = [module.keycloak_db, module.iam, module.vpc_connector]
}

# ============================================================================
# MICROSERVICES
# ============================================================================

# Auth Service
module "auth_service" {
  source = "../../modules/microservice"

  project_id            = var.project_id
  region                = var.region
  environment           = "dev"
  service_name          = "auth-service"
  service_account_email = module.service_accounts.runtime_sa_emails["auth-service"]

  database_name = "auth"
  db_user_name  = "auth_user"

  # PRIVATE IP CONFIGURATION
  public_ip_enabled          = false
  private_network_id         = module.vpc.vpc_id
  private_network_dependency = [module.vpc.private_vpc_connection]
  authorized_networks        = []

  # VPC CONNECTOR
  vpc_connector_id   = module.vpc_connector.connector_id
  vpc_egress_setting = "PRIVATE_RANGES_ONLY"

  additional_env_vars = {
    KEYCLOAK_URL = module.keycloak.service_url
  }

  depends_on = [module.iam, module.vpc, module.vpc_connector]
}

# HR Service
module "hr_service" {
  source = "../../modules/microservice"

  project_id            = var.project_id
  region                = var.region
  environment           = "dev"
  service_name          = "hr-service"
  service_account_email = module.service_accounts.runtime_sa_emails["hr-service"]

  database_name = "hr"
  db_user_name  = "hr_user"

  # PRIVATE IP CONFIGURATION
  public_ip_enabled          = false
  private_network_id         = module.vpc.vpc_id
  private_network_dependency = [module.vpc.private_vpc_connection]
  authorized_networks        = []

  # VPC CONNECTOR
  vpc_connector_id   = module.vpc_connector.connector_id
  vpc_egress_setting = "PRIVATE_RANGES_ONLY"

  additional_env_vars = {
    AUTH_SERVICE = module.auth_service.service_url
  }

  depends_on = [module.iam, module.vpc, module.vpc_connector]
}

# Finance Service
module "finance_service" {
  source = "../../modules/microservice"

  project_id            = var.project_id
  region                = var.region
  environment           = "dev"
  service_name          = "finance-service"
  service_account_email = module.service_accounts.runtime_sa_emails["finance-service"]

  database_name = "finance"
  db_user_name  = "finance_user"

  # PRIVATE IP CONFIGURATION
  public_ip_enabled          = false
  private_network_id         = module.vpc.vpc_id
  private_network_dependency = [module.vpc.private_vpc_connection]
  authorized_networks        = []

  # VPC CONNECTOR
  vpc_connector_id   = module.vpc_connector.connector_id
  vpc_egress_setting = "PRIVATE_RANGES_ONLY"

  additional_env_vars = {
    AUTH_SERVICE = module.auth_service.service_url
  }

  depends_on = [module.iam, module.vpc, module.vpc_connector]
}
