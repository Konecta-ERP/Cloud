variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "The region for the Artifact Registry repository"
  type        = string
}

variable "repository_id" {
  description = "The ID of the repository"
  type        = string
}

variable "description" {
  description = "Description of the repository"
  type        = string
  default     = "Docker repository for ERP microservices"
}

variable "immutable_tags" {
  description = "Whether tags are immutable"
  type        = bool
  default     = false
}
