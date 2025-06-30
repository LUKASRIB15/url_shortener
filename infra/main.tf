data "archive_file" "url_shortener_artefact" {
  type        = "zip"
  source_file = "${local.lambdas_path}/index.js"
  output_path = "files/url-shortener.zip"
}

resource "aws_lambda_function" "url_shortener" {
  function_name = "url-shortener"
  handler       = "index.handler"
  role          = aws_iam_role.url_shortener_iam_role.arn
  runtime       = "nodejs20.x"
  
  filename         = data.archive_file.url_shortener_artefact.output_path
  source_code_hash = data.archive_file.url_shortener_artefact.output_base64sha256

  timeout = 5
  memory_size = 128
}

resource "aws_lambda_function_url" "url_shortener_url" {
  function_name      = aws_lambda_function.url_shortener.function_name
  authorization_type = "NONE"
}