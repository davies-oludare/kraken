# Create a new workspace
resource "astro_workspace" "leep_utilities_workspace" {
  name                  = "Leep Utilities Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
