data "terraform_remote_state" "workspace" {
  backend = "local"
  config = {
    path = "../workspaces/terraform.tfstate"
  }
}
