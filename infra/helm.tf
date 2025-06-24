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
    value = var.image_tag # This tag exists in your 'quote-api' repo
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


# helm.tf
resource "helm_release" "quote_api_prod" { // New TF resource for prod
  name             = "quote-api-prod"     // Helm release name in Kubernetes for prod
  chart            = "../charts/quote-api"  // Adjusted path
  namespace        = kubernetes_namespace.prod_ns.metadata[0].name
  create_namespace = false // Terraform's kubernetes_namespace handles this

  set {
    name  = "image.repository"
    value = "${google_artifact_registry_repository.main_quote_api_repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main_quote_api_repo.repository_id}/quote-api"
  }
  set {
    name  = "image.tag"
    # This tag should be what your 'prod' trigger in Cloud Build pushes as 'latest' or its $SHORT_SHA
    value = var.image_tag # Or make this a variable: var.prod_image_tag
  }
  set {
    name  = "serviceAccount.name"
    value = "quote-api-ksa"
  }
  set {
    name  = "projectId"
    value = var.project_id
  }
  # Add any prod-specific values (e.g., replicaCount, different config)
  # set {
  #   name = "replicaCount"
  #   value = "2"
  # }

  depends_on = [
    google_container_node_pool.secure_pool_2,
    google_service_account_iam_member.quote_api_gsa_2_wi_user_prod,
    kubernetes_namespace.prod_ns,
    google_artifact_registry_repository.main_quote_api_repo
  ]
}

