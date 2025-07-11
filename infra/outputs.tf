output "api_base_url" {
  description = "URL base da sua API. Use POST /create para criar e GET /{shortCode} para redirecionar."
  value       = aws_apigatewayv2_stage.url_shortener_stage.invoke_url
}