# GitHub Actions and WordPress on AWS

This repository contains the core activity implementation: GitHub Actions runs Terraform to provision and destroy a WordPress demo EC2 host. Terraform state is stored in a private, encrypted S3 bucket with versioning.

## Files

- `.github/workflows/terraform.yaml`: manual workflow dispatch with **apply** and **destroy** choices.
- `tf/`: Terraform configuration for an Amazon Linux EC2 host, an HTTP security group, and WordPress bootstrap.
- `tf/backend.tf`: remote state configuration for the course activity's S3 bucket.
- `.gitignore`: excludes local state, plans, caches, variable files, and private keys.

## GitHub repository setup

Add these Actions repository secrets before running the workflow:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

Use the dedicated IAM identity created for this activity. Its permissions must cover the Terraform resources and S3 state bucket. Never commit credentials, Terraform state, or a plan file.

The selected AWS account and region must contain the existing EC2 key pair named `oliver-kp`. The workflow uses `us-east-1`.

## Run the activity

1. Open **Actions** and select **Terraform_apply_and_destroy**.
2. Choose **Run workflow** with `apply` to create the demo.
3. To produce the required destroy evidence, run the workflow again with `destroy`.
4. Save a screenshot of the successful GitHub Actions destroy run showing the Terraform destroy result and add it to this repository (for example, `screenshots/terraform-destroy-success.png`).

The WordPress host and HTTP security group are billable AWS resources while present. Run the destroy operation after the demonstration.

## Core deliverables

- Terraform configuration checked into the repository.
- GitHub Actions workflow that applies and destroys the configuration.
- Terraform remote state stored in S3.
- Screenshot of the successful GitHub Actions destroy run in `screenshots/`.
