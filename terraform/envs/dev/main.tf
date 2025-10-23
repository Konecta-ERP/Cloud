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
# FIREWALL RULES
# ============================================================================

module "firewall" {
  source = "../../modules/firewall"

  project_id = var.project_id
  vpc_name   = "erp-vpc-dev"
  network    = module.vpc.vpc_self_link

  subnet_cidr   = "10.0.0.0/24"
  pods_cidr     = "10.1.0.0/16"
  services_cidr = "10.2.0.0/16"
  master_cidr   = "172.16.0.0/28"

  enable_ssh = false # Set to true if you need SSH access for debugging

  depends_on = [module.vpc]
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
# GKE CLUSTER
# ============================================================================

module "gke_cluster" {
  source = "../../modules/gke_cluster"

  project_id   = var.project_id
  location     = var.region # Regional cluster for HA
  cluster_name = "erp-cluster-dev"

  network    = module.vpc.vpc_name
  subnetwork = module.vpc.subnet_name

  master_ipv4_cidr_block      = "172.16.0.0/28"
  cluster_autoscaling_profile = "OPTIMIZE_UTILIZATION"

  pods_secondary_range_name     = module.vpc.pods_range_name
  services_secondary_range_name = module.vpc.services_range_name

  deletion_protection = false

  labels = {
    environment = "dev"
    managed_by  = "terraform"
  }

  network_dependency = module.vpc.private_vpc_connection

  depends_on = [module.vpc]
}

# ============================================================================
# GKE NODE POOL
# ============================================================================

module "gke_node_pool_default" {
  source = "../../modules/gke_node_pool"

  project_id     = var.project_id
  location       = var.region
  cluster_name   = module.gke_cluster.cluster_name
  node_pool_name = "primary-node-pool"

  initial_node_count = 1
  min_node_count     = 1
  max_node_count     = 3

  machine_type = "e2-medium"
  disk_size_gb = 50
  preemptible  = false # Use preemptible for dev (cheaper!), # Default pool should generally be non-preemptible

  service_account = module.service_accounts.terraform_sa_email

  labels = {
    environment = "dev"
    managed_by  = "terraform"
  }

  tags = ["gke-node", "erp-dev"]

  depends_on = [module.gke_cluster]
}


# New: GKE Node Pool for Preemptible/Spot Workloads
# This is where significant cost savings come from for interruptible workloads.
module "gke_node_pool_spot" {
  source = "../../modules/gke_node_pool"

  project_id     = var.project_id
  location       = var.region
  cluster_name   = module.gke_cluster.cluster_name
  node_pool_name = "spot-node-pool"

  # Allow scaling down to zero for maximum cost savings when no spot workloads are running
  initial_node_count = 0
  min_node_count     = 0
  max_node_count     = 5 # Allow more scale for burstable spot workloads

  machine_type = "e2-small"    # Even smaller and cheaper instance type
  disk_size_gb = 30            # Smaller disk for temporary workloads
  disk_type    = "pd-standard" # Cheaper disk
  preemptible  = true          # CRITICAL: Enables Spot VM behavior for this pool

  service_account = module.service_accounts.terraform_sa_email # Or a dedicated SA for spot

  labels = {
    environment   = "dev"
    managed_by    = "terraform"
    workload_type = "spot" # Useful label for identifying node purpose
  }
  tags        = ["gke-node", "erp-dev", "spot-pool"]
  node_taints = [{ key = "workload-type", value = "spot", effect = "PREFER_NO_SCHEDULE" }] # Taint to direct pods
  depends_on  = [module.gke_cluster]
}

# ============================================================================
# CLOUD NAT (for private GKE nodes to access internet)
# ============================================================================

module "cloud_nat" {
  source = "../../modules/cloud_nat"

  project_id  = var.project_id
  region      = var.region
  network     = module.vpc.vpc_name
  router_name = "erp-router-dev"
  nat_name    = "erp-nat-dev"

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  enable_logging = true
  log_filter     = "ERRORS_ONLY"

  depends_on = [module.vpc]
}
# # ============================================================================
# # MONITORING
# # ============================================================================

module "monitoring" {
  source = "../../modules/monitoring"

  project_id             = var.project_id
  alert_email            = "aminsherif659@gmail.com"  # Or use a variable
  enable_alerts          = true
  dashboard_display_name = "ERP Konecta - Dev Environment Monitoring"

  # Alert thresholds (all optional - have defaults)
  latency_threshold_ms        = 2000  # 2 seconds
  error_rate_threshold        = 0.05  # 5%
  cpu_utilization_threshold   = 0.85  # 85%

  # Alert durations (optional)
  alert_duration_latency = 300  # 5 minutes
  alert_duration_error   = 300  # 5 minutes
  alert_duration_cpu     = 600  # 10 minutes

  depends_on = [module.gke_cluster, module.project_services]
}
