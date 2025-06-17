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
