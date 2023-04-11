############# IAM #############
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.this.json
}

############# Lambda #############
resource "aws_lambda_function" "this" {
  function_name = var.name
  runtime       = var.runtime
  role          = aws_iam_role.this.arn
  handler       = var.handler
  filename      = var.filename
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.apigateway_execution_arn}/*/*"
}

############# CloudWatch #############
resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${var.name}"
  retention_in_days = var.cloudwatch_log_group_retention
}

############# API GateWay #############
resource "aws_apigatewayv2_stage" "this" {
  name        = var.name
  api_id      = var.apigateway_api_id
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "this" {
  api_id = var.apigateway_api_id

  integration_uri    = aws_lambda_function.this.invoke_arn
  integration_type   = var.apigatewayv2_integration_type
  integration_method = var.apigateway_integration_method
}

resource "aws_apigatewayv2_route" "this" {
  api_id = var.apigateway_api_id

  route_key = var.apigateway_route_key
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}
