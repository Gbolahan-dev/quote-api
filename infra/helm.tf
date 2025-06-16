resource "helm_release" "quote_api_staging_2" {
  name             = "quote-api"
  chart            = "../../quote-api/charts/quote-api" # <- path to your chart
  namespace        = "staging"
  create_namespace = true

  set {
    name  = "image.repository"
    value = "${var.region}-docker.pkg.dev/${var.project_id}/quote-api/quote-api"
  }
  set {
    name  = "image.tag"
    value = "latest" # hard-coded test tag
  }

  depends_on = [google_container_node_pool.secure_pool_2]
}


