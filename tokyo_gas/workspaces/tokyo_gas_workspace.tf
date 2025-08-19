# Create a new workspace
resource "astro_workspace" "tokyo_gas_workspace" {
  name                  = "Tokyo Gas Workspace"
  description           = "Customer Workspace"
  cicd_enforced_default = false
}
