# cluster.tf

resource "google_container_cluster" "primary_2" {
  project                  = var.project_id
  name                     = "quote-api-cluster-2"
  location                 = var.zone // This should be var.zone if it's a zonal cluster, or var.region if regional
  remove_default_node_pool = true
  initial_node_count       = 1 # This creates a temporary default pool that gets removed.

  /* This node_config is for the *temporary* default node pool
  node_config {
    disk_type    = "pd-standard"
    disk_size_gb = 30
  }*/

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    stack_type = "IPV4"
  }
}

# GKE Node Pool: "secure_pool_2" using gke-node-sa-2
resource "google_container_node_pool" "secure_pool_2" {
  # --- Top-level arguments for the node pool ---
  name       = "secure-pool-2"
  project    = var.project_id
  location   = var.zone # Must match the cluster's location type (zone for zonal, region for regional)
  cluster    = google_container_cluster.primary_2.name
  node_count = null # Set to null if using autoscaling, or set an initial_node_count here.
  # initial_node_count can also be used here instead of node_count for clarity.

  lifecycle {
    ignore_changes = [
      # nested attribute path syntax
      node_config[0].resource_labels
    ]
  }

  # --- Nested blocks ---
  autoscaling {
    min_node_count = 1
    max_node_count = 3
    # location_policy = "BALANCED" # This is often a default
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = "e2-medium"
    disk_type       = "pd-standard"
    disk_size_gb    = 50
    service_account = google_service_account.gke_node_sa_2.email # Correct reference

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]

    image_type = "COS_CONTAINERD"

    labels = {
      # example-label = "example-value"
    }
    tags = [
      # "example-network-tag"
    ]


    kubelet_config {
      cpu_manager_policy = "none" # This is a common default
      # cpu_cfs_quota        = false # another common default
      # pod_pids_limit       = -1    # another common default
    }

    shielded_instance_config { # Optional, but good to define explicitly
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    }
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
    # strategy        = "SURGE" # Default
  }

  # --- Meta-argument ---
  depends_on = [
    google_container_cluster.primary_2
  ]
}
