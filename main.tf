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
  name = "serverless_example_lambda"

  assume_role_policy = data.aws_iam_policy_document.function_assume_role_policy.json
}
