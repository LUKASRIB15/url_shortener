terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.0.0"
    }
  }
}

provider "aws" {
  region  = "sa-east-1"
  profile = "AdministratorAccess-528757812389"
}