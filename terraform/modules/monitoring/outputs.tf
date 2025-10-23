##############################################
# OUTPUTS - monitoring/outputs.tf
##############################################

output "dashboard_id" {
  description = "Unique identifier of the ERP Monitoring Dashboard."
  value       = google_monitoring_dashboard.erp_app_dashboard.id
}

# # COMMENTED OUT - Alert policies not created yet
# output "alert_policy_ids" {
#   description = "List of created alert policy IDs for the ERP system."
#   value = [
#     google_monitoring_alert_policy.high_latency.id,
#     google_monitoring_alert_policy.high_error_rate.id,
#     google_monitoring_alert_policy.high_pod_cpu.id,
#   ]
# }
# 
# output "alert_policy_names" {
#   description = "Human-readable names of created alert policies."
#   value = [
#     google_monitoring_alert_policy.high_latency.display_name,
#     google_monitoring_alert_policy.high_error_rate.display_name,
#     google_monitoring_alert_policy.high_pod_cpu.display_name,
#   ]
# }

output "notification_channel_id" {
  description = "Email notification channel ID used for ERP alerts."
  value       = google_monitoring_notification_channel.email.id
}

output "notification_channel_email" {
  description = "Email address associated with the notification channel."
  value       = var.alert_email
}
