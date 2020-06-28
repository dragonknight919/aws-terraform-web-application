resource "aws_dynamodb_table" "minimal_backend_table" {
  name           = "minimal-backend-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "N"
  }
}

data "archive_file" "backend_function_package" {
  type        = "zip"
  source_file = "./backend_lambda_function.py"
  output_path = "./backend_lambda_function.zip"
}

resource "aws_lambda_function" "minimal_backend_function" {
  function_name = "minimal-backend-function"

  filename = data.archive_file.backend_function_package.output_path

  handler = "backend_lambda_function.lambda_handler"
  runtime = "python3.8"

  role = aws_iam_role.function_assume_role.arn
}

data "aws_iam_policy_document" "function_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "function_assume_role" {
  name = "lambda-dynamodb-role"

  assume_role_policy = data.aws_iam_policy_document.function_assume_role_policy.json
}

data "aws_iam_policy_document" "function_permissions" {
  statement {
    sid       = "LambdaDynamodb"
    actions   = ["dynamodb:Scan", "dynamodb:PutItem"]
    resources = [aws_dynamodb_table.minimal_backend_table.arn]
  }
}

resource "aws_iam_role_policy" "function_permissions" {
  name = "lambda-dynamodb-policy"
  role = aws_iam_role.function_assume_role.id

  policy = data.aws_iam_policy_document.function_permissions.json
}

resource "aws_api_gateway_rest_api" "minimal_api" {
  name = "minimal-api"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.minimal_api.id
  resource_id   = aws_api_gateway_rest_api.minimal_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.minimal_api.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.minimal_backend_function.invoke_arn
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.minimal_api.id
  parent_id   = aws_api_gateway_rest_api.minimal_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.minimal_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.minimal_api.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.minimal_backend_function.invoke_arn
}

resource "aws_api_gateway_deployment" "minimal" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.minimal_api.id
  stage_name  = "minimal"
}

resource "aws_lambda_permission" "api_invoke_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.minimal_backend_function.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.minimal_api.execution_arn}/*/*"
}

resource "aws_s3_bucket" "minimal_frontend_bucket" {
  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_object" "minimal_index" {
  bucket       = aws_s3_bucket.minimal_frontend_bucket.id
  key          = "index.html"
  source       = "./index.html"
  acl          = "public-read"
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "minimal_script" {
  bucket = aws_s3_bucket.minimal_frontend_bucket.id
  key    = "index.js"
  content = templatefile(
    "./index.js",
    { api_url = aws_api_gateway_deployment.minimal.invoke_url }
  )
  acl = "public-read"
}
