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
