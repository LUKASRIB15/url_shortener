locals {
  url_shortener_creation_lambda_path = "${path.module}/../url-shortener-creation/dist"
  url_shortener_redirection_lambda_path = "${path.module}/../url-shortener-redirection/dist"
  layers_path  = "${path.module}/layers"

  common_tags = {
    Project   = "Lambda Layers with Terraform"
    CreatedAt = formatdate("YYYY-MM-DD", timestamp())
    Iac       = true
    Owner     = "Lucas Ribeiro"
  }
}