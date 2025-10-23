##############################################
# VARIABLES - monitoring/variables.tf
##############################################

variable "project_id" {
  description = "The ID of the Google Cloud project where monitoring resources will be created."
  type        = string
  default = "erp-konecta"
}

variable "alert_email" {
  description = "Primary email address that will receive ERP system alert notifications."
  type        = string
  default = "aminsherif659@gmail.com"
}

variable "enable_alerts" {
  description = "Whether to enable alert policies (set to false for test environments)."
  type        = bool
  default     = true
}

variable "dashboard_display_name" {
  description = "Display name for the ERP Monitoring Dashboard."
  type        = string
  default     = "ERP Application Performance Dashboard (GKE)"
}

variable "latency_threshold_ms" {
  description = "Threshold in milliseconds for high API latency alert (95th percentile)."
  type        = number
  default     = 2000
}

variable "error_rate_threshold" {
  description = "Threshold for triggering the high API error rate alert (as a fraction, e.g., 0.05 = 5%)."
  type        = number
  default     = 0.05
}

variable "cpu_utilization_threshold" {
  description = "Threshold for triggering the high Pod CPU usage alert (fraction of 1, e.g., 0.85 = 85%)."
  type        = number
  default     = 0.85
}

variable "alert_duration_latency" {
  description = "Duration (in seconds) the high latency condition must hold before triggering an alert."
  type        = number
  default     = 300
}

variable "alert_duration_error" {
  description = "Duration (in seconds) the high error rate condition must hold before triggering an alert."
  type        = number
  default     = 300
}

variable "alert_duration_cpu" {
  description = "Duration (in seconds) the high CPU utilization condition must hold before triggering an alert."
  type        = number
  default     = 600
}
