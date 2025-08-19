# Create a new workspace
resource "astro_workspace" "saint_john_energy_workspace" {
  name                  = "Saint John Energy Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
