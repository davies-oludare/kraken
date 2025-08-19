# Create a new workspace
resource "astro_workspace" "meridian_workspace" {
  name                  = "Meridian Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
