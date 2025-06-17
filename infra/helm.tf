# helm.tf
resource "helm_release" "quote_api_staging_2" {
  name             = "quote-api"
  chart            = "../charts/quote-api" # Ensure this path is correct from ~/quote-api/infra/terraform
  namespace        = kubernetes_namespace.staging_ns.metadata[0].name
  create_namespace = false # Or false if namespace resource manages it + depends_on

  set {
    name  = "image.repository"
    # HARDCODE THE FULL IMAGE PATH (EXCLUDING TAG)
    value = "us-central1-docker.pkg.dev/daring-emitter-457812-v7/quote-api/quote-api"
  }
  set {
    name  = "image.tag"
    # HARDCODE AN EXISTING TAG
    value = "2c3d431" # This tag exists in your 'quote-api' repo
  }
  set {
    name  = "serviceAccount.name"
    value = "quote-api-ksa"
  }
  set {
    name  = "projectId"
    value = var.project_id # var.project_id must be "daring-emitter-457812-v7"
  }

  depends_on = [
    google_container_node_pool.secure_pool_2,
    google_service_account_iam_member.quote_api_gsa_2_wi_user_staging,
    kubernetes_namespace.staging_ns
  ]
}
