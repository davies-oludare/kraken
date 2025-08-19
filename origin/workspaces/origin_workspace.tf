# Create a new workspace
resource "astro_workspace" "origin_workspace" {
  name                  = "Origin Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
