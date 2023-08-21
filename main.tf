resource "harness_platform_gitops_agent" "tf_gitops_tutorial_agent" {
  identifier = ""
  account_id = ""
  project_id = "default_project"
  org_id     = "default"
  name       = ""
  type       = "MANAGED_ARGO_PROVIDER"
  metadata {
    namespace         = "default"
    high_availability = false
  }
}

data "harness_platform_gitops_agent_deploy_yaml" "tf_gitops_tutorial_agent_yaml" {
  identifier = "${harness_platform_gitops_agent.tf_gitops_tutorial_agent.identifier}"
  account_id = ""
  project_id = "default_project"
  org_id     = "default"
  namespace  = "default"
}

output "gitops_agent_yaml" {
  value = data.harness_platform_gitops_agent_deploy_yaml.tf_gitops_tutorial_agent_yaml.yaml
}
resource "harness_platform_gitops_repository" "tf_gitops_tutorial_repo" {
  identifier = ""
  account_id = ""
  project_id = "default_project"
  org_id     = "default"
  agent_id   = ""
  repo {
    repo            = "https://github.com/nicklotz/harnesscd-example-apps.git"
    name            = "harnesscd-example-apps"
    insecure        = true
    connection_type = "HTTPS_ANONYMOUS"
  }
  upsert = true
  gen_type = "UNSET"
}

resource "harness_platform_gitops_cluster" "tf_gitops_tutorial_cluster" {
  identifier = ""
  account_id = ""
  project_id = "default_project"
  org_id     = "default"
  agent_id   = ""

  request {
    upsert = false
    cluster {
      server = "https://kubernetes.default.svc"
      name   = "name"
      config {
        tls_client_config {
          insecure = true
        }
        cluster_connection_type = "IN_CLUSTER"
      }

    }
  }
}
