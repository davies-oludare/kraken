terraform {
  required_providers {
    astro = {
      source  = "astronomer/astro"
      version = "1.0.7"
    }
  }
}

provider "astro" {
  organization_id = "cmeh2oc1h1tc701hunt25r0gj"
  
  # Token can be provided via environment variable 'ASTRO_API_TOKEN'
}