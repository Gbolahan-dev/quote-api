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

# Add this to the end of iam_sa.tf

resource "google_service_account_iam_member" "quote_api_gsa_2_wi_user_staging" { // This is Instruction #2
  service_account_id = google_service_account.quote_api_gsa_2.name // The Google ID badge
  role               = "roles/iam.workloadIdentityUser"         // The "permission to link"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_namespace.staging_ns.metadata[0].name}/quote-api-ksa]"
                                                                  // Links to Kubernetes badge "quote-api-ksa"
                                                                  // in the "staging" room (Instruction #1)
  depends_on = [
    google_service_account.quote_api_gsa_2,
    kubernetes_namespace.staging_ns // Link only after Google ID badge and Staging Room are ready
  ]
}


resource "google_service_account_iam_member" "quote_api_gsa_2_wi_user_prod" {
  service_account_id = google_service_account.quote_api_gsa_2.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_namespace.prod_ns.metadata[0].name}/quote-api-ksa]"
  depends_on         = [google_service_account.quote_api_gsa_2, kubernetes_namespace.prod_ns]
}


########################################################
# 2.2 Cloud Build Deployer SA: "cloudbuild-deployer-tf"
########################################################
resource "google_service_account_iam_member" "cb_can_act_as_compute_for_run" {
 # project = var.project_id
  # This is the ID badge of the Cloud Run machine
  service_account_id = "projects/${var.project_id}/serviceAccounts/158322366388-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser" # This role grants the "act as" permission
  # This is your Cloud Build worker
  member             = "serviceAccount:${google_service_account.cloudbuild_deployer_2.email}"
}

resource "google_service_account" "cloudbuild_deployer_2" {
  project      = var.project_id
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


resource "google_project_iam_member" "cb_deployer_2_gke_viewer" {
  project = var.project_id
  role    = "roles/container.clusterViewer"
  member  = "serviceAccount:${google_service_account.cloudbuild_deployer_2.email}"
}

resource "google_project_iam_member" "cb_deployer_2_compute_viewer" {
  project = var.project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.cloudbuild_deployer_2.email}"
}

resource "google_project_iam_member" "cb_deployer_2_iam_sa_viewer" {
  project = var.project_id
  role    = "roles/iam.serviceAccountViewer"
  member  = "serviceAccount:${google_service_account.cloudbuild_deployer_2.email}"
}


resource "google_storage_bucket_iam_member" "cb_deployer_2_tf_state_bucket_object_admin" {
  bucket  = "tf-state-daring-emitter-457812-v7"  
  role    = "roles/storage.objectAdmin"
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

