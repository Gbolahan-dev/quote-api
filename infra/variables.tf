variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "region" {
  description = "GCP region (e.g., us-central1)"
  type        = string
  default     = "us-central1"
}
variable "zone" {
  description = "GCP zone (e.g., us-central1-a)"
  type        = string
  default     = "us-central1-a"
}
variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "quote-api-cluster"
}

variable "github_owner" {
  description = "The owner of the GitHub repository."
  type        = string
  default     = "Gbolahan-dev"
}

variable "github_repo_name" {
  description = "The name of the GitHub repository."
  type        = string
  default     = "quote-api"
}
