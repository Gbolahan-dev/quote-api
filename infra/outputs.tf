############################################
# 4. Outputs for easy reference
############################################

output "artifact_registry_url_2" {
  description = "The Docker URL for the 'quote-api' image in the 'quote-api' Artifact Registry repository."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/quote-api/quote-api"
}

output "quote_api_gsa_2_email" {
  value = google_service_account.quote_api_gsa_2.email
}

output "cloudbuild_deployer_2_email" {
  value = google_service_account.cloudbuild_deployer_2.email
}

output "gke_node_sa_2_email" {
  value = google_service_account.gke_node_sa_2.email
}

output "gke_cluster_2_endpoint" {
  value = google_container_cluster.primary_2.endpoint
}

output "gke_cluster_2_ca_certificate" {
  value = google_container_cluster.primary_2.master_auth[0].cluster_ca_certificate
}

