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

/*
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
*/


  # infra/cloudbuild_triggers.tf

resource "google_cloudbuild_trigger" "pr_trigger_tf" {
  project         = var.project_id
  name            = "quote-api-pr-trigger"
  description     = "PR to main -> Run fast validation checks (lint, test)"
  service_account = google_service_account.cloudbuild_deployer_2.id

  # This tells the trigger to get its steps from the YAML file.
  # This is a top-level setting.
  filename = "cloudbuild.pr.yaml"

  # We also need to define the build configuration to specify options.
  # This block looks empty, but it's where we add a few important details.
  
    # We must include an empty substitutions map if we define a build block.
    substitutions = {}

    # This 'options' block is where we solve the logging error.

  # The GitHub configuration remains the same.
  github {
    owner = var.github_owner
    name  = var.github_repo_name
    pull_request {
      branch          = "^main$"
      comment_control = "COMMENTS_DISABLED"
    }
  }

 
}

/*
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
}*/
