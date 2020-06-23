output "api_url" {
  value = aws_api_gateway_deployment.minimal.invoke_url
}

output "website_endpoint" {
  value = aws_s3_bucket.minimal_frontend_bucket.website_endpoint
}
