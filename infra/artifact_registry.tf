###############################################################################
# 1. Artifact Registry (new name with “2”)
###############################################################################
resource "google_artifact_registry_repository" "main_quote_api_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = "quote-api"
  format        = "DOCKER"
  description   = "Terraform-managed Docker repo for quote-api (v2)"
}

