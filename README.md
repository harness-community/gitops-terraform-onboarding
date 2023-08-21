# Harness GitOps onboarding via Terraform

## WIP high level instructions

### Provisioning
1. Clone this repo to a machine that has Terraform command line tools installed, and can connect to a local K8 cluster.
1. Change into **gitops-terraform-onboarding/** and run `terraform init`.
1. Fill in **terraform.tfvars** with the appropriate info.
1. Run `export TF_VAR_harness_api_token=<access token>` (don't add your PAT to .tfvars).
1. Run `terraform plan` and then `terraform apply`, confirming when prompted.

### Cleanup
1. Run `terraform destroy`, confirming when prompted.


