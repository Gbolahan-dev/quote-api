############################################
# 2.1 Pod GSA: "quote-api-gsa-tf" + IAM roles
############################################

resource "google_service_account" "quote_api_gsa_2" {
  account_id   = "quote-api-gsa-2"
  display_name = "GSA for quote-api pods (Terraform)"
}

resource "google_project_iam_member" "quote_api_gsa_2_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.quote_api_gsa_2.email}"
}

resource "google_project_iam_member" "quote_api_gsa_2_logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.quote_api_gsa_2.email}"
}


########################################################
# 2.2 Cloud Build Deployer SA: "cloudbuild-deployer-tf"
########################################################

resource "google_service_account" "cloudbuild_deployer_2" {
  account_id   = "cloudbuild-deployer-2"
  display_name = "Cloud Build Deployer SA (Terraform)"
}

resource "google_project_iam_member" "cb_deployer_2_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloudbuild_deployer_2.email}"
}

resource "google_project_iam_member" "cb_deployer_2_gke_dev" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.cloudbuild_deployer_2.email}"
}

resource "google_project_iam_member" "cb_deployer_2_run_dev" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.cloudbuild_deployer_2.email}"
}

resource "google_project_iam_member" "cb_deployer_2_logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild_deployer_2.email}"
}

########################################################
# 2.3 GKE Node Pool SA: "gke-node-sa-tf" + IAM roles
########################################################

resource "google_service_account" "gke_node_sa_2" {
  account_id   = "gke-node-sa-2"
  display_name = "GKE Node Pool SA (Terraform)"
}

resource "google_project_iam_member" "node_sa_2_ar_reader" {
  project = var.project_id
  role = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.gke_node_sa_2.email}"
}
resource "google_project_iam_member" "node_sa_2_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_node_sa_2.email}"
}

resource "google_project_iam_member" "node_sa_2_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_node_sa_2.email}"
}

