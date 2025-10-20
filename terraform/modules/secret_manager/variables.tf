variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "secret_id" {
  description = "The ID of the secret"
  type        = string
}

variable "secret_data" {
  description = "The secret data to store"
  type        = string
  sensitive   = true
}

variable "labels" {
  description = "Labels to apply to the secret"
  type        = map(string)
  default     = {}
}
