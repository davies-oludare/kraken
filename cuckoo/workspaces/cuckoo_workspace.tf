# Create a new workspace
resource "astro_workspace" "cuckoo_workspace" {
  name                  = "Cuckoo Energy Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
