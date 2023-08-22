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

resource "null_resource" "deploy_agent_resources_to_cluster" {
  triggers = {
    content = local_file.gitops_agent_yaml.content
  }
  provisioner "local-exec" {
    when = create
    command = "kubectl apply -f gitops_agent.yaml; sleep 40"
  }
  depends_on = [local_file.gitops_agent_yaml]
}

resource "null_resource" "remove_agent_resources_from_cluster" {
  provisioner "local-exec" {
    when = destroy
    command = "kubectl delete -f gitops_agent.yaml"
  }
  depends_on = [local_file.gitops_agent_yaml]
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
  depends_on = [null_resource.deploy_agent_resources_to_cluster]
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
  depends_on = [harness_platform_gitops_repository.tf_gitops_tutorial_repo]
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
  depends_on = [harness_platform_gitops_cluster.tf_gitops_tutorial_cluster]
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
  depends_on = [harness_platform_gitops_cluster.tf_gitops_tutorial_cluster]
}


resource "harness_platform_gitops_applications" "guestbook" {
  application {
    metadata {
      annotations = {}
      labels = {
        "harness.io/serviceRef" = "testservice"
        "harness.io/envRef"     = "testenv"
      }
    name = "guestbook"
    }
    spec {
      sync_policy {
        automated {
          self_heal = true
        }
        sync_options = [
          "PrunePropagationPolicy=undefined",
          "CreateNamespace=false",
          "Validate=false",
          "skipSchemaValidations=false",
          "autoCreateNamespace=false",
          "pruneLast=false",
          "applyOutofSyncOnly=false",
          "Replace=false",
          "retry=false"
        ]
      }
      source {
        target_revision = "master"
        repo_url        = var.repo_url
        path            = "guestbook"

      }
      destination {
        namespace = var.agent_namespace
        server    = "https://kubernetes.default.svc"
      }
    }
  }
  project_id = var.project_id
  org_id     = var.org_id
  account_id = var.account_id
  identifier = "guestbook"
  cluster_id = var.cluster_identifier
  repo_id    = var.repo_identifier
  agent_id   = var.agent_identifier
  name       = "guestbook"
  depends_on = [harness_platform_service.gitops_guestbook_service]
}




