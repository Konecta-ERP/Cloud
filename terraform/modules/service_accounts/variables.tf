variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "terraform_sa_name" {
  description = "The account ID for the Terraform service account"
  type        = string
  default     = "terraform-sa"
}

variable "build_sa_name" {
  description = "The account ID for the CI/CD build service account"
  type        = string
  default     = "cicd-build-sa"
}

variable "service_names" {
  description = "List of microservice names to create runtime service accounts for"
  type        = list(string)
  default     = []
}
