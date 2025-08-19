# Create a new workspace
resource "astro_workspace" "octopus_enery_workspace" {
  name                  = "Octopus Energy Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}