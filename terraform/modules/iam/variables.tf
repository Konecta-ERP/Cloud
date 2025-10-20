variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "terraform_sa_email" {
  description = "Email of the Terraform service account"
  type        = string
}

variable "build_sa_email" {
  description = "Email of the CI/CD build service account"
  type        = string
}

variable "runtime_sa_emails" {
  description = "Map of service names to runtime service account emails"
  type        = map(string)
}
