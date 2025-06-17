# cloudbuild_triggers.tf

resource "google_cloudbuild_trigger" "prod_trigger_tf" {
  project         = var.project_id
  name            = "quote-api-prod-trigger" // Exact name of your trigger in GCP
  description     = "Push to main -> build, push, deploy prod GKE & Cloud Run"
  filename        = "cloudbuild.yaml"        // Path to cloudbuild.yaml in your repo
  service_account = google_service_account.cloudbuild_deployer_2.id // Use TF-managed SA

  github {
    owner = var.github_owner
    name  = var.github_repo_name
    push {
      branch = "^main$" // Regex for the main branch
    }
  }

  substitutions = {
    _TARGET_ENV = "prod"
    // Add any other _DEFAULT_ substitutions your trigger has in the console
  }
  // If your existing trigger has specific build log settings:
  // include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}

resource "google_cloudbuild_trigger" "pr_trigger_tf" {
  project         = var.project_id
  name            = "quote-api-pr-trigger" // Exact name of your trigger in GCP
  description     = "PR to main -> build/test staging image"
  filename        = "cloudbuild.yaml"
  service_account = google_service_account.cloudbuild_deployer_2.id // Use TF-managed SA

  github {
    owner = var.github_owner
    name  = var.github_repo_name
    pull_request {
      branch           = "^main$" // PRs targeting main
      comment_control  = "COMMENTS_DISABLED" // Check your existing setting in console
      # invert_regex   = false (default)
    }
  }
  substitutions = {
    _TARGET_ENV = "staging"
    // Add any other _DEFAULT_ substitutions your trigger has
  }
  // include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}

# Define your third trigger ("quote-api-trigger") similarly.
# Example:
resource "google_cloudbuild_trigger" "legacy_cloud_run_trigger_tf" {
  project         = var.project_id
  name            = "quote-api-trigger" // Exact name from GCP
  description     = "CI/CD trigger for deploying quote-api to Cloud Run." // From your 'helm list' output earlier
  filename        = "cloudbuild.yaml"
  service_account = google_service_account.cloudbuild_deployer_2.id

  github {
    owner = var.github_owner
    name  = var.github_repo_name
    push {
      branch = "^main$" # Assuming it's also a push to main
    }
  }
  # Check console for its specific substitutions, might be different or none
  substitutions = {
     _TARGET_ENV = "prod" // Or whatever this trigger is meant for
  }
}
