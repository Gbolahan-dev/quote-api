###############################################################################
# 1. Artifact Registry (new name with “2”)
###############################################################################
/* resource "google_artifact_registry_repository" "docker_repo_2" {
  project       = var.project_id
  location      = var.region
  repository_id = "quote-api-docker-2"
  format        = "DOCKER"
  description   = "Terraform-managed Docker repo for quote-api (v2)"
} */

