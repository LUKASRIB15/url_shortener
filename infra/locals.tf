locals {
  lambdas_path = "${path.module}/../dist"
  layers_path  = "${path.module}/layers"

  common_tags = {
    Project   = "Lambda Layers with Terraform"
    CreatedAt = formatdate("YYYY-MM-DD", timestamp())
    Iac       = true
    Owner     = "Lucas Ribeiro"
  }
}