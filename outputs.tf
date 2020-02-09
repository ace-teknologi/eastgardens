output "cloudfront_distribution" {
  value = aws_cloudfront_distribution.distribution
}


output "lambda_function" {
  value = aws_lambda_function.eastgardens
}

output "iam_role" {
  value = aws_iam_role.eastgardens
}
