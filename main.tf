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

resource "kubectl_manifest" "gitops_agent_cluster_deployment" {
    yaml_body = <<YAML
${data.harness_platform_gitops_agent_deploy_yaml.tf_gitops_tutorial_agent_yaml.yaml}
YAML
}

resource "harness_platform_gitops_repository" "tf_gitops_tutorial_repo" {
  identifier = var.repo_identifier
  account_id = var.account_id
  project_id = var.project_id
  org_id     = var.org_id
  agent_id   = var.agent_identifier
  repo {
    repo            = var.repo_url
    name            = var.repo_name
    insecure        = true
    connection_type = "HTTPS_ANONYMOUS"
  }
  upsert = true
  gen_type = "UNSET"
}

resource "harness_platform_gitops_cluster" "tf_gitops_tutorial_cluster" {
  identifier = var.cluster_identifier
  account_id = var.account_id
  project_id = var.project_id
  org_id     = var.org_id
  agent_id   = var.agent_identifier

  request {
    upsert = false
    cluster {
      server = "https://kubernetes.default.svc"
      name   = var.cluster_name
      config {
        tls_client_config {
          insecure = true
        }
        cluster_connection_type = "IN_CLUSTER"
      }

    }
  }
}

output "gitops_agent_yaml" {
  value = data.harness_platform_gitops_agent_deploy_yaml.tf_gitops_tutorial_agent_yaml.yaml
}
