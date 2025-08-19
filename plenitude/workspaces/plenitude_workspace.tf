# Create a new workspace
resource "astro_workspace" "plenitude_workspace" {
  name                  = "Plenitude Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
