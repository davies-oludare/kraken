# Create a new workspace
resource "astro_workspace" "anwb_workspace" {
  name                  = "ANWB Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
