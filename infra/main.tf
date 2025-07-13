# ------------ Lambda function: Create Url Shortener ------------

data "archive_file" "url_shortener_creation_artefact" {
  type        = "zip"
  source_file = "${local.url_shortener_creation_lambda_path}/index.js"
  output_path = "files/url-shortener-creation.zip"
}

resource "aws_lambda_function" "url_shortener_creation" {
  function_name = "url-shortener-creation"
  handler       = "index.handler"
  role          = aws_iam_role.url_shortener_iam_role.arn
  runtime       = "nodejs20.x"
  
  filename         = data.archive_file.url_shortener_creation_artefact.output_path
  source_code_hash = data.archive_file.url_shortener_creation_artefact.output_base64sha256

  timeout = 5
  memory_size = 128
}

# ------------ Lambda function: Redirect Url Shortener ------------

data "archive_file" "url_shortener_redirection_artefact" {
  type        = "zip"
  source_file = "${local.url_shortener_redirection_lambda_path}/index.js"
  output_path = "files/url-shortener-redirection.zip"
}

resource "aws_lambda_function" "url_shortener_redirection" {
  function_name = "url-shortener-redirection"
  handler       = "index.handler"
  role          = aws_iam_role.url_shortener_iam_role.arn
  runtime       = "nodejs20.x"
  
  filename         = data.archive_file.url_shortener_redirection_artefact.output_path
  source_code_hash = data.archive_file.url_shortener_redirection_artefact.output_base64sha256

  timeout = 5
  memory_size = 128
}

# ------------ Bucket s3 ------------

resource "aws_s3_bucket" "url_shortener_bucket" {
  bucket = local.bucket_name

  tags = {
    Name = "Url Shortener"
    Iac  = true
  }
}

# ------------ API Gateway ------------

resource "aws_apigatewayv2_api" "url_shortener_api" {
  name = "url-shortener-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "url_shortener_stage" {
  api_id = aws_apigatewayv2_api.url_shortener_api.id
  name = "$default"
  auto_deploy = true
} 

resource "aws_apigatewayv2_integration" "create_url_shortener_integration" {
  api_id = aws_apigatewayv2_api.url_shortener_api.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.url_shortener_creation.invoke_arn
}

resource "aws_apigatewayv2_route" "create_url_shortener_route" {
  api_id = aws_apigatewayv2_api.url_shortener_api.id
  route_key = "POST /create"
  target = "integrations/${aws_apigatewayv2_integration.create_url_shortener_integration.id}"
}

resource "aws_apigatewayv2_integration" "redirect_url_shortener_integration" {
  api_id = aws_apigatewayv2_api.url_shortener_api.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.url_shortener_redirection.invoke_arn
}

resource "aws_apigatewayv2_route" "redirect_url_shortener_route" {
  api_id = aws_apigatewayv2_api.url_shortener_api.id
  route_key = "GET /{shortUrlCode}"
  target = "integrations/${aws_apigatewayv2_integration.redirect_url_shortener_integration.id}"
}