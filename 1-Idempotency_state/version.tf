terraform {
  required_version = ">= 1.14.7"

  backend "local" {
    path = "./state/terraform.tfstate"
  }

}