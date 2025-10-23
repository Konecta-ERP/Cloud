resource "google_monitoring_dashboard" "erp_app_dashboard" {
  project = var.project_id

  dashboard_json = jsonencode({
    displayName = "Konecta ERP - Production Monitoring (GKE)"
    gridLayout = {
      columns = 2
      widgets = [

        # --- POD CPU USAGE (WORKS!) ---
        {
          title = "Pod CPU Usage (cores)"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"k8s_pod\" metric.type=\"kubernetes.io/pod/cpu/core_usage_time\""
                    aggregation = {
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_MEAN"
                      groupByFields      = ["resource.namespace_name", "resource.pod_name"]
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
            chartOptions = { mode = "COLOR" }
            yAxis = {
              label = "CPU cores"
              scale = "LINEAR"
            }
          }
        },

        # --- POD MEMORY USAGE (WORKS!) ---
        {
          title = "Pod Memory Usage (bytes)"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"k8s_pod\" metric.type=\"kubernetes.io/pod/memory/used_bytes\""
                    aggregation = {
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_MEAN"
                      groupByFields      = ["resource.namespace_name", "resource.pod_name"]
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
            chartOptions = { mode = "COLOR" }
            yAxis = {
              label = "Memory (bytes)"
              scale = "LINEAR"
            }
          }
        },

        # --- NODE CPU UTILIZATION (WORKS!) ---
        {
          title = "Node CPU Utilization (%)"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"k8s_node\" metric.type=\"kubernetes.io/node/cpu/allocatable_utilization\""
                    aggregation = {
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_MEAN"
                      groupByFields      = ["resource.node_name"]
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
            chartOptions = { mode = "COLOR" }
            yAxis = {
              label = "CPU %"
              scale = "LINEAR"
            }
          }
        },

        # --- NODE MEMORY UTILIZATION (WORKS!) ---
        {
          title = "Node Memory Utilization (%)"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"k8s_node\" metric.type=\"kubernetes.io/node/memory/allocatable_utilization\""
                    aggregation = {
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_MEAN"
                      groupByFields      = ["resource.node_name"]
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
            chartOptions = { mode = "COLOR" }
            yAxis = {
              label = "Memory %"
              scale = "LINEAR"
            }
          }
        },

        # --- CONTAINER RESTARTS (WORKS!) ---
        {
          title = "Container Restarts"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"k8s_container\" metric.type=\"kubernetes.io/container/restart_count\""
                    aggregation = {
                      perSeriesAligner   = "ALIGN_DELTA"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["resource.namespace_name", "resource.pod_name"]
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
            chartOptions = { mode = "COLOR" }
            yAxis = {
              label = "Restart count"
              scale = "LINEAR"
            }
          }
        },

        # --- NETWORK RECEIVED (WORKS!) ---
        {
          title = "Network Bytes Received"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"k8s_pod\" metric.type=\"kubernetes.io/pod/network/received_bytes_count\""
                    aggregation = {
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["resource.namespace_name"]
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
            chartOptions = { mode = "COLOR" }
            yAxis = {
              label = "Bytes/sec"
              scale = "LINEAR"
            }
          }
        }
      ]
    }
  })
}

##############################################
# NOTIFICATION CHANNEL (EMAIL)
##############################################
resource "google_monitoring_notification_channel" "email" {
  project      = var.project_id
  display_name = "erp-alert-email"
  type         = "email"

  labels = {
    email_address = var.alert_email
  }
}

##############################################
# ALERT POLICIES - COMMENTED OUT
##############################################
# These alert policies are commented out because the required metrics
# don't exist until applications are deployed to the GKE cluster.
# 
# TO ENABLE: Uncomment these resources after DevOps deploys applications
# to GKE (Week 4 or Week 5), then run:
#   terraform apply
#
# Also uncomment corresponding outputs in:
#   - modules/monitoring/outputs.tf
#   - envs/dev/outputs.tf

# # 1️⃣ High API Latency
# resource "google_monitoring_alert_policy" "high_latency" {
#   project               = var.project_id
#   display_name          = "erp-high-api-latency"
#   combiner              = "OR"
#   notification_channels = [google_monitoring_notification_channel.email.id]
# 
#   depends_on = [google_monitoring_notification_channel.email]
# 
#   documentation {
#     content   = "Triggered when 95th percentile API latency exceeds 2000 ms for 5 minutes."
#     mime_type = "text/markdown"
#   }
# 
#   conditions {
#     display_name = "95th Percentile Latency > 2000ms"
#     condition_threshold {
#       filter          = "metric.type=\"kubernetes.googleapis.com/container/request_latencies\" resource.type=\"k8s_container\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = 2000
#       duration        = "300s"
#       aggregations {
#         alignment_period   = "60s"
#         per_series_aligner = "ALIGN_PERCENTILE_95"
#       }
#       trigger { count = 1 }
#     }
#   }
# }
# 
# # 2️⃣ High API Error Rate
# resource "google_monitoring_alert_policy" "high_error_rate" {
#   project               = var.project_id
#   display_name          = "erp-high-api-error-rate"
#   combiner              = "OR"
#   notification_channels = [google_monitoring_notification_channel.email.id]
# 
#   depends_on = [google_monitoring_notification_channel.email]
# 
#   documentation {
#     content   = "Triggered when 5xx error rate exceeds 5% of requests for 5 minutes."
#     mime_type = "text/markdown"
#   }
# 
#   conditions {
#     display_name = "5xx Error Rate > 5% of Requests"
#     condition_threshold {
#       filter          = "metric.type=\"kubernetes.googleapis.com/container/request_count\" resource.type=\"k8s_container\" metric.label.response_code_class=\"5xx\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = 0.05
#       duration        = "300s"
#       aggregations {
#         alignment_period   = "60s"
#         per_series_aligner = "ALIGN_RATE"
#       }
#       trigger { count = 1 }
#     }
#   }
# }
# 
# # 3️⃣ High Pod CPU Usage
# resource "google_monitoring_alert_policy" "high_pod_cpu" {
#   project               = var.project_id
#   display_name          = "erp-high-pod-cpu"
#   combiner              = "OR"
#   notification_channels = [google_monitoring_notification_channel.email.id]
# 
#   depends_on = [google_monitoring_notification_channel.email]
# 
#   documentation {
#     content   = "Triggered when pod CPU utilization exceeds 85% for 10 minutes."
#     mime_type = "text/markdown"
#   }
# 
#   conditions {
#     display_name = "Pod CPU > 85%"
#     condition_threshold {
#       filter          = "metric.type=\"kubernetes.googleapis.com/container/cpu/utilization\" resource.type=\"k8s_container\""
#       comparison      = "COMPARISON_GT"
#       threshold_value = 0.85
#       duration        = "600s"
#       aggregations {
#         alignment_period   = "60s"
#         per_series_aligner = "ALIGN_MEAN"
#       }
#       trigger { count = 1 }
#     }
#   }
# }
