# Harness GitOps onboarding via Terraform

## WIP high level instructions

### Provisioning
1. Clone this repo to a machine that has Terraform command line tools installed, and can connect to a local K8 cluster.
1. Change into **gitops-terraform-onboarding/agent/** and run `terraform init`.
1. Fill in **terraform.tfvars** with the appropriate values.
1. Run `export TF_VAR_harness_api_token=<access token>` (don't add your PAT to .tfvars).
1. Run `terraform plan` and then `terraform apply`, confirming when prompted.
1. The kubernetes manifest will now be saved as a file called **gitops_agent.yaml**. Run `kubectl apply -f gitops_agent.yaml`.
1. Change into **gitops-terraform-onboarding/app/**. Run `terraform init`.
1. Fill in **terraform.tfvars** with the appropriate values.
1. Run `terraform plan` and then `terraform apply`.
1. Run `kubectl get pods` and verify the guestbook application was deployed.

### Cleanup
1. Run `terraform destroy` from the **gitops-terraform-onboarding/app/** directory.
1. Change into **gitops-terraform-onboarding/agent/**.
1. Run `kubectl destroy -f gitops_agent.yaml`.
3. Run `terraform destroy` from the **gitops-terraform-onboarding/agent/** directory.


