# Create a new workspace
resource "astro_workspace" "maingau_workspace" {
  name                  = "Maingau Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
