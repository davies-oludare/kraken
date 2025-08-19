# Create a new workspace
resource "astro_workspace" "severn_trent_workspace" {
  name                  = "Severn Trent Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
