# Create a new workspace
resource "astro_workspace" "good_energy_workspace" {
  name                  = "Good Energy Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
