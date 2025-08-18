## Create 5 workspaces and 3 deployments (prod/dev/test) per workspace

locals {
  workspace_names = [
    "Workspace 1",
    "Workspace 2",
    "Workspace 3",
    "Workspace 4",
    "Workspace 5",
  ]

  deployment_environments = {
    prod = {
      is_development_mode = false
      name_suffix         = "Prod"
      description_suffix  = "Production"
    }
    dev = {
      is_development_mode = true
      name_suffix         = "Dev"
      description_suffix  = "Development"
    }
    test = {
      is_development_mode = true
      name_suffix         = "Test"
      description_suffix  = "Test"
    }
  }
}

# Workspaces
resource "astro_workspace" "workspaces" {
  for_each              = toset(local.workspace_names)
  name                  = each.value
  description           = "Workspace ${each.value}"
  cicd_enforced_default = false
}

# Deployments per workspace and environment
resource "astro_deployment" "deployments" {
  for_each = {
    for pair in flatten([
      for ws_name, ws in astro_workspace.workspaces :
      [for env, cfg in local.deployment_environments :
        {
          key     = "${ws_name}-${env}"
          ws_name = ws_name
          env     = env
          cfg     = cfg
        }
      ]
    ]) : pair.key => pair
  }

  name                    = "${each.value.ws_name} ${each.value.cfg.name_suffix}"
  description             = "${each.value.cfg.description_suffix} deployment for ${each.value.ws_name}"
  type                    = "STANDARD"
  cloud_provider          = "AWS"
  region                  = "us-east-1"
  contact_emails          = []
  default_task_pod_cpu    = "0.25"
  default_task_pod_memory = "0.5Gi"
  executor                = "CELERY"
  is_cicd_enforced        = true
  is_dag_deploy_enabled   = true
  is_development_mode     = each.value.cfg.is_development_mode
  is_high_availability    = false
  resource_quota_cpu      = "10"
  resource_quota_memory   = "20Gi"
  scheduler_size          = "SMALL"
  workspace_id            = astro_workspace.workspaces[each.value.ws_name].id
  environment_variables   = []
  worker_queues = [{
    name               = "default"
    is_default         = true
    astro_machine      = "A5"
    max_worker_count   = 10
    min_worker_count   = 0
    worker_concurrency = 1
  }]
}