output "enabled_services" {
  description = "List of enabled Google Cloud APIs"
  value = [
    google_project_service.cloud_run.service,
    google_project_service.artifact_registry.service,
    google_project_service.cloud_build.service,
    google_project_service.cloud_sql_admin.service,
    google_project_service.secret_manager.service,
    google_project_service.compute.service,
    google_project_service.service_networking.service,
    google_project_service.container.service,
  ]
}
