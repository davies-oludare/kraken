# Create a new workspace
resource "astro_workspace" "portsmouth_water_workspace" {
  name                  = "Portsmouth Water Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
