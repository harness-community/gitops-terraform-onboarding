resource "harness_platform_gitops_repository" "gitops_repo" {
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
  depends_on = [null_resource.deploy_agent_resources_to_cluster]
}

resource "harness_platform_gitops_cluster" "gitops_cluster" {
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
  depends_on = [harness_platform_gitops_repository.gitops_repo]
}

resource "harness_platform_service" "gitops_guestbook_service" {
  identifier  = var.service_name
  name        = var.service_name
  description = var.service_name
  org_id      = var.org_id
  project_id  = var.project_id
  yaml = <<-EOT
         service:
           name: testservice
           identifier: testservice
           serviceDefinition:
             type: Kubernetes
             spec: {}
           gitOpsEnabled: true     
         EOT
  depends_on = [harness_platform_gitops_cluster.gitops_cluster]
}

resource "harness_platform_environment" "gitops_guestbook_env" {
  identifier = var.env_name
  name       = var.env_name
  org_id     = var.org_id
  project_id = var.project_id
  type       = "PreProduction"
  yaml = <<-EOT
         environment:
           name: testenv
           identifier: testenv
           description: ""
           tags: {}
           type: PreProduction
           orgIdentifier: default
           projectIdentifier: default_project
           variables: []
       EOT
  depends_on = [harness_platform_gitops_cluster.gitops_cluster]
}

