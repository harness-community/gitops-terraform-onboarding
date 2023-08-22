# Harness GitOps onboarding via Terraform

## WIP high level instructions

### Provisioning
1. Clone this repo to a machine that has Terraform command line tools installed, and can connect to a local K8 cluster.
1. Change into **gitops-terraform-onboarding/** and run `terraform init`.
1. Open **terraform.tfvars**. This file is pre-filled with demo values for the Harness resources. Leave them as they are or change to reflect your environment. 
1. Run `export TF_VAR_harness_api_token=<your Harness access token>`. Be sure not to add your PAT to .tfvars).
1. Run `terraform plan`. Terraform should output that 9 resoures will be created.
1. Run `terraform apply` and confirm when prompted. Terraform will provision the Harness GitOps agent, install the agent in the cluster, create other Harness resources, and deploy the guestbook application. 
1. Run `kubectl get pods` and verify the guestbook application was deployed.
1. Run `kubectl port-forward svc/guestbook-ui 8080:80` and verify the guestbook application opens as expected.

### Cleanup
1. Run `terraform destroy` from the **gitops-terraform-onboarding/** directory. Confirm when prompted.
1. Run `kubectl get pods` to confirm the Harness resources were deleted.
