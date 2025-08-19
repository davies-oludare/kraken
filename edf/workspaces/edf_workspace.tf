# Create a new workspace
resource "astro_workspace" "edf_workspace" {
  name                  = "EDF Energy Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
