
provider "google" {
  project = var.project_id
  region  = var.region
  # zone = var.zone
}

data "google_client_config" "default" {}

data "google_container_cluster" "cluster_for_providers" {
  name     = google_container_cluster.primary_2.name
  location = google_container_cluster.primary_2.location
  project  = var.project_id
}

provider "kubernetes" {
  host                   = data.google_container_cluster.cluster_for_providers.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster_for_providers.master_auth[0].cluster_ca_certificate)

}


provider "helm" {
  kubernetes {
    host                   = data.google_container_cluster.cluster_for_providers.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.cluster_for_providers.master_auth[0].cluster_ca_certificate)
  }
}
