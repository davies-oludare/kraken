# Create a new workspace
resource "astro_workspace" "e-on_workspace" {
  name                  = "E.ON Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
