# Production-Grade Node.js App on GKE: Quote API

This project demonstrates the deployment of a Node.js application ("Quote API") onto Google Kubernetes Engine (GKE) using a production-grade DevOps toolchain. It features Infrastructure as Code (IaC) with Terraform, containerization with Docker, artifact management with Google Artifact Registry, and a robust CI/CD pipeline orchestrated by Google Cloud Build for automated builds, tests, and staged deployments to staging and production environments.

## Table of Contents (Optional but Recommended)

*   [Architecture Overview](#architecture-overview)
*   [Prerequisites](#prerequisites)
*   [Repository Structure](#repository-structure)
*   [Setup Instructions](#setup-instructions)
*   [Development Workflow](#development-workflow)
*   [Deployment Process](#deployment-process)
*   [Accessing the Application](#accessing-the-application)
*   [Key Commands](#key-commands)
*   [Troubleshooting](#troubleshooting)

## Architecture Overview

(A high-level diagram and description of the components will be added here - See Task 4.2)

This project consists of the following main components:
*   **Quote API Application:** A simple Node.js Express application serving quotes.
*   **Docker:** Used to containerize the Node.js application.
*   **Google Artifact Registry:** Stores the Docker images.
*   **Google Kubernetes Engine (GKE):** Hosts the containerized application in staging and production environments.
*   **Helm:** Used to package and manage Kubernetes deployments (Service, Deployment, HPA, PodMonitoring).
*   **Terraform:** Manages all GCP infrastructure as code, including the GKE cluster, Node Pools, Artifact Registry, IAM Service Accounts, and Cloud Build Triggers. Terraform also manages the Helm releases to GKE.
*   **Google Cloud Storage (GCS):** Hosts the Terraform state backend.
*   **Google Cloud Build:** Orchestrates the CI/CD pipeline:
    *   **PR Pipeline (`cloudbuild.pr.yaml`):** Runs linting and tests on Pull Requests.
    *   **Main Pipeline (`cloudbuild.yaml`):** Builds Docker images, pushes to Artifact Registry, and triggers Terraform deployments to GKE (staging then production with a simulated approval gate). Also handles existing Cloud Run deployments.
*   **Google Cloud IAM:** Manages permissions for service accounts (Workload Identity for GKE pods, Cloud Build SA).
*   **Google Cloud Managed Service for Prometheus:** Provides monitoring for GKE workloads.

## Prerequisites

To set up and work with this project, you will need the following tools installed and configured:

*   **Git:** For version control.
*   **Google Cloud SDK (`gcloud`):** Authenticated and configured for your target GCP project.
    *   Ensure components are up-to-date: `gcloud components update`
*   **`kubectl`:** For interacting with the GKE cluster.
    *   Can be installed via `gcloud components install kubectl`
*   **`terraform`:** (Version ~1.5.7 or compatible) For managing infrastructure.
*   **`helm`:** (Version ~3.x) For inspecting Helm releases (though Terraform manages deployment).
*   **Node.js and `pnpm`:** For local application development and running scripts (if making app changes).
*   **Access:**
    *   A GCP Project where you have permissions to create/manage GKE clusters, IAM roles, Artifact Registry, Cloud Build, GCS, etc.
    *   A GitHub account (or other Git provider) to host the repository.

## Repository Structure
.
├── Dockerfile # Defines the application's Docker image
├── README.md # This file
├── charts/ # Helm chart for the quote-api application
│ └── quote-api/
├── cloudbuild.pr.yaml # Cloud Build pipeline for Pull Request validation
├── cloudbuild.yaml # Main Cloud Build pipeline for deployments
├── index.js # Main application code
├── infra/ # Terraform configurations
│ ├── backend.tf # Terraform GCS backend configuration
│ ├── cluster.tf # GKE Cluster and Node Pool definitions
│ ├── helm.tf # Helm release definitions managed by Terraform
│ ├── iam_sa.tf # Service Account and IAM binding definitions
│ ├── namespaces.tf # Kubernetes namespace definitions
│ ├── variables.tf # Terraform variable definitions
│ └── ... # Other Terraform files
├── package.json # Node.js project manifest
├── package-lock.json # (or pnpm-lock.yaml)
└── quotes.json # Data for the quote API


## Setup Instructions

These instructions assume you are setting up the project in a new GCP environment or for a new developer.

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/Gbolahan-dev/quote-api.git
    cd quote-api
    ```

2.  **Configure GCP Project and Authentication:**
    Ensure your `gcloud` CLI is pointing to the correct project and is authenticated:
    ```bash
    gcloud config set project daring-emitter-457812-v7
    gcloud auth application-default login
    ```

3.  **Set Up Terraform Backend GCS Bucket:**
    This project uses a GCS bucket for Terraform state. If this bucket doesn't exist, you need to create it first.
    *   Bucket name is defined in `infra/backend.tf` (e.g., `tf-state-your-project-id`).
    *   Create the bucket: `gsutil mb gs://tf-state-daring-emitter-457812-v7/`
    *   Enable versioning on the bucket (recommended): `gsutil versioning set on gs://tf-state-daring-emitter-457812-v7/

4.  **Prepare Terraform Variables:**
    *   Navigate to the `infra` directory: `cd infra`
    *   Create a `terraform.tfvars` file if it doesn't exist or if you need to override default variable values. At a minimum, you will likely need to set `project_id`:
        ```terraform
        // infra/terraform.tfvars
        project_id = "daring-emitter-457812-v7"
        // Add other variables like region, zone, cluster_name if you want to override defaults
        ```

5.  **Initialize and Apply Terraform:**
    *   From the `infra` directory:
        ```bash
        terraform init
        terraform apply
        ```
    *   This will provision all the GCP resources, including the GKE cluster, Artifact Registry, IAM Service Accounts, Cloud Build Triggers, and deploy the initial Helm releases for staging and production (likely with the default "latest" image tag from `variables.tf`).

6.  **Configure Manual Approval for Production Trigger (One-Time UI Step):**
    *   Go to the Cloud Build Triggers page in the GCP console.
    *   Edit your main production trigger (e.g., `quote-api-prod-trigger`).
    *   Under "Advanced settings" -> "Approval", check "Require approval".
    *   Set the "Step ID to approve" to `Hold for Production Approval`.
    *   Save the trigger. *(Note: If the UI doesn't allow per-step approval, this step is skipped, and the "Hold" step acts as a timed/logged pause).*

## Development Workflow

1.  **Create a Feature Branch:**
    ```bash
    git checkout -b feature/your-new-feature
    ```
2.  **Make Code Changes:** Modify application code, Terraform configurations, Helm charts, etc.
3.  **Commit and Push:**
    ```bash
    git add .
    git commit -m "feat: Describe your feature"
    git push -u origin feature/your-new-feature
    ```
4.  **Open a Pull Request (PR):**
    *   Go to GitHub and open a PR from your feature branch to `main`.
    *   The `cloudbuild.pr.yaml` pipeline will automatically run, performing linting and tests.
    *   The PR requires these checks to pass and (if configured) at least one approval before merging.

## Deployment Process

Merging a PR to the `main` branch triggers the `quote-api-prod-trigger` and the `cloudbuild.yaml` pipeline, which executes the following staged deployment:

1.  **Build & Push Image:** A new Docker image is built and tagged with the Git `SHORT_SHA` and `latest`. It's pushed to Google Artifact Registry.
2.  **Deploy to Cloud Run (if configured):** The `latest` image is deployed to Cloud Run, potentially with a canary rollout.
3.  **Deploy to GKE Staging:**
    *   Terraform is invoked: `terraform apply -target=helm_release.quote_api_staging_2 -var="image_tag=${SHORT_SHA}"`
    *   This updates the `staging` namespace on GKE to use the new `SHORT_SHA`-tagged image.
4.  **Hold for Production Approval:**
    *   The pipeline logs a message: "Staging GKE has been updated... Verify... and approve..."
    *   *(If UI approval is configured, the build will pause here in the Cloud Build UI, awaiting manual approval).*
    *   At this stage, manually verify the staging environment (see "Accessing the Application").
5.  **Deploy to GKE Production:**
    *   *(If UI approval is configured, click "Approve" in the Cloud Build UI).*
    *   Terraform is invoked: `terraform apply -target=helm_release.quote_api_prod -var="image_tag=${SHORT_SHA}"`
    *   This updates the `prod` namespace on GKE to use the same `SHORT_SHA`-tagged image that was verified in staging.

## Accessing the Application

After deployment, the application will be accessible via LoadBalancer IPs.

1.  **Get Staging LoadBalancer IP:**
    ```bash
    kubectl get svc -n staging -l app.kubernetes.io/instance=quote-api -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}'
    ```
    (Replace `app.kubernetes.io/instance=quote-api` with the correct label for your staging service if different. Your staging Helm release name is `quote-api`.)
    Access via: `http://<STAGING_LB_IP>:8080/`

2.  **Get Production LoadBalancer IP:**
    ```bash
    kubectl get svc -n prod -l app.kubernetes.io/instance=quote-api-prod -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}'
    ```
    (Replace `app.kubernetes.io/instance=quote-api-prod` with the correct label if different. Your production Helm release name is `quote-api-prod`.)
    Access via: `http://<PROD_LB_IP>:8080/`

## Key Commands

*   **View running GKE pods (staging):** `kubectl get pods -n staging -o wide`
*   **View running GKE pods (production):** `kubectl get pods -n prod -o wide`
*   **View logs for a GKE pod (staging):** `kubectl logs -n staging <pod-name-from-above>`
*   **View logs for a GKE pod (production):** `kubectl logs -n prod <pod-name-from-above>`
*   **Run local Terraform plan (from `infra/` dir):** `terraform plan -var="image_tag=some-tag"`
*   **Force-unlock Terraform state (DANGEROUS - from `infra/` dir, if lock is stale):**
    ```bash
    # First, find the lock ID from the error message
    terraform force-unlock <LOCK_ID>
    # Or, if you need to remove the lock file directly:
    gsutil rm gs://tf-state-daring-emitter-457812-v7/quote-api/default.tflock
    ```

## Troubleshooting

*   **Terraform State Lock Errors in Cloud Build:**
    *   Usually caused by a previous pipeline run failing to release the lock.
    *   **Fix:** Manually delete the `default.tflock` file from your GCS Terraform state backend bucket (e.g., `gsutil rm gs://<bucket>/<prefix>/default.tflock`) and retry the Cloud Build.
*   **Cloud Build Permission Errors:**
    *   Ensure the Cloud Build Service Account (`cloudbuild-deployer-2@...`) has all necessary IAM roles defined in `infra/iam_sa.tf` and applied. This includes roles for Artifact Registry, GKE, Cloud Run, GCS (for Terraform state), and project viewer roles for Terraform to read resource states.
*   **Image Pull Errors in GKE:**
    *   Ensure Workload Identity is correctly set up:
        *   Kubernetes Service Account (`quote-api-ksa`) exists in `staging` and `prod` namespaces.
        *   GCP Service Account (`quote-api-gsa-2@...`) exists and has `roles/artifactregistry.reader`.
        *   The IAM binding `roles/iam.workloadIdentityUser` links the KSA to the GSA for each namespace (defined in `infra/iam_sa.tf`).
        *   The `serviceAccountName: quote-api-ksa` is set in your Helm chart's Deployment spec.

---
