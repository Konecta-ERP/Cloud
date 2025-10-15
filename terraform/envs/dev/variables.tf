variable "project_id" {
  description = "The Google Cloud project ID for the dev environment"
  type        = string
}

variable "region" {
  description = "The primary region for dev environment resources"
  type        = string
  default     = "europe-west1"
}
