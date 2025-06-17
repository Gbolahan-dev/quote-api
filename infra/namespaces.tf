# namespaces.tf (or add to an existing .tf file)

resource "kubernetes_namespace" "staging_ns" {
  metadata {
    name = "staging"
    # Optional: Add labels or annotations if needed
    # labels = {
    #   environment = "staging"
    # }
  }

  # Ensure the namespace is created only after the cluster is ready
  depends_on = [google_container_cluster.primary_2]
}

/*
resource "kubernetes_namespace" "prod_ns" {
  metadata {
    name = "prod" // We'll use the 'prod' namespace for convention
  }
  depends_on = [google_container_cluster.primary_2]
}
*/
