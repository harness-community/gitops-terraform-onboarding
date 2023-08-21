resource "harness_platform_gitops_agent" "tf_gitops_tutorial_agent" {
  identifier = var.agent_identifier
  account_id = var.account_id
  project_id = var.project_id
  org_id     = var.org_id
  name       = var.agent_name
  type       = "MANAGED_ARGO_PROVIDER"
  metadata {
    namespace         = var.agent_namespace
    high_availability = false
  }
}

data "harness_platform_gitops_agent_deploy_yaml" "tf_gitops_tutorial_agent_yaml" {
  identifier = "${harness_platform_gitops_agent.tf_gitops_tutorial_agent.identifier}"
  account_id = var.account_id
  project_id = var.project_id
  org_id     = var.org_id
  namespace  = var.agent_namespace
}

resource "local_file" "gitops_agent_yaml" {
  filename = "gitops_agent.yaml"
  content  = data.harness_platform_gitops_agent_deploy_yaml.tf_gitops_tutorial_agent_yaml.yaml
}
