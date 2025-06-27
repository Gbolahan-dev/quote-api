# Operations Runbook: Quote API

This document outlines standard operational procedures for releasing new versions and rolling back deployments for the Quote API application.

## 1. Standard Release Procedure

The release process is fully automated via the CI/CD pipeline and follows the development workflow.

1.  **Create a Feature Branch:** All work must be done on a feature branch checked out from `main`.
2.  **Open a Pull Request (PR):** Open a PR from the feature branch to `main`.
3.  **Automated Checks:** The `quote-api-pr-trigger` will run automatically, performing linting and tests. These checks must pass.
4.  **Code Review & Merge:** The PR must be reviewed and approved (if configured). Once all checks pass, the PR is merged into the `main` branch.
5.  **Staged Deployment:** Merging to `main` triggers the `quote-api-prod-trigger` pipeline, which executes the following:
    a. A new Docker image is built and tagged with the Git `SHORT_SHA`.
    b. The new image is deployed to the **staging** GKE environment via Terraform (`terraform apply -target=helm_release.quote_api_staging_2`).
    c. The pipeline pauses (simulated) at the `Hold for Production Approval` step.
    d. **Manual Verification:** At this point, the operator must verify the staging environment is working correctly by checking the staging LoadBalancer IP.
    e. **Approve Deployment:** The operator approves the build in the Cloud Build UI (if configured) or allows the pipeline to proceed.
    f. The same image is then deployed to the **production** GKE environment via Terraform (`terraform apply -target=helm_release.quote_api_prod`).
6.  **Final Verification:** The operator verifies that the production environment is working correctly.

## 2. Emergency Rollback Procedure

This procedure should be used if a production deployment is found to be faulty and needs to be reverted to the last known good state **as quickly as possible**. This method prioritizes speed over maintaining a perfect Git history match.

1.  **Identify the Last Good Version:**
    *   Go to the [Cloud Build History](https://console.cloud.google.com/cloud-build/builds) page.
    *   Find the **last successful build** that was deployed to production *before* the faulty one.
    *   Copy its `SHORT_SHA` (Git commit ID). This is your `<LAST_GOOD_SHORT_SHA>`.

2.  **Execute Terraform Rollback from Your Local Machine:**
    *   Ensure your local environment is authenticated with GCP (`gcloud auth application-default login`).
    *   Navigate to the `infra/` directory.
    *   Run the following command, replacing `<LAST_GOOD_SHORT_SHA>` with the ID you found in step 1:

    ```bash
    terraform apply -auto-approve \
      -var="image_tag=<LAST_GOOD_SHORT_SHA>" \
      -target=helm_release.quote_api_prod
    ```
    *   This command forces Terraform to redeploy the production Helm release using the last known good image tag.

3.  **Verify Production:**
    *   `curl` the production LoadBalancer IP to confirm the application has been rolled back and is responding correctly.

4.  **Follow Up with a Git Revert:**
    *   After the emergency is over, you **must** follow up with the "Proper IaC Rollback" procedure below to ensure the Git `main` branch once again reflects the true state of production.

## 3. Proper IaC Rollback Procedure

This is the standard, clean way to roll back. It is slower than the emergency procedure but keeps Git as the single source of truth.

1.  **Identify the Bad Commit:**
    *   Find the `SHA` of the faulty commit that was merged into `main`.

2.  **Create a Revert Commit:**
    *   From an up-to-date `main` branch, create a new branch: `git checkout -b fix/revert-bad-commit`
    *   Run the `git revert` command:
        ```bash
        git revert <BAD_COMMIT_SHA>
        ```
    *   This will create a *new* commit that undoes the changes from the bad commit. Resolve any merge conflicts if they occur.

3.  **Push and Open a PR:**
    *   Push the revert branch to GitHub: `git push origin fix/revert-bad-commit`
    *   Open a Pull Request for this branch.

4.  **Follow the Standard Release Procedure:**
    *   Let the PR checks pass, get the PR approved, and merge it.
    *   The main pipeline will now run, building the code from the previous (good) state and deploying it through the normal staging -> production flow.
