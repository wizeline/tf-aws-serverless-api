output "apigateway_url" {
  value = join("", [aws_apigatewayv2_stage.this.invoke_url, var.apigateway_route_key_path])
}

output "custom_dns_url" {
  value = join("", ["https://", aws_apigatewayv2_api_mapping.this[0].domain_name])
}
