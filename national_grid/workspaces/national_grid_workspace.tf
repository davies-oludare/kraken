# Create a new workspace
resource "astro_workspace" "national_grid_workspace" {
  name                  = "National Grid Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
