resource "aws_cloudfront_distribution" "distribution" {
  comment = "302 redirect distribution for ${var.namespace} created by Eastgardens"

  enabled = true

  aliases = var.hosts

  price_class = "PriceClass_All"

  default_cache_behavior {
    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.eastgardens.qualified_arn
      include_body = false
    }

    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    target_origin_id = "null"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1200
  }

  # the origin is not used - lambda always returns a response
  origin {
    origin_id   = "null"
    domain_name = "dev.null"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false

    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = var.ssl_support_method
    minimum_protocol_version = var.minimum_protocol_version
  }
}

locals {
  timestamp = replace(timestamp(), "/[TZ\\-\\:]/", "")
}

resource "random_pet" "eastgardens" {
  keepers = {
    file_md5 = data.archive_file.eastgardens.output_md5
  }
}

# @TODO work out how to taint this if we change the code - probably by modifying the zip below
resource "aws_lambda_function" "eastgardens" {
  filename      = data.archive_file.eastgardens.output_path
  function_name = "Eastgardens-${var.namespace}-${random_pet.eastgardens.id}"
  handler       = "eastgardens.eastgardens"
  role          = aws_iam_role.eastgardens.arn
  description   = "HTTP 302 redirect function"
  runtime       = "python3.7" # cloudfront doesn't support 3.8 yet
  publish       = true

  lifecycle {
    # These things are really hard to delete!!
    create_before_destroy = true
  }

}

locals {
  # If fallthrough is origin, wrap it in quotes so it is nice for python
  # @TODO have a boolean for origin_fallthrough that does this
  fallthrough = var.custom_fallthrough_response == "origin" ? "'origin'" : var.custom_fallthrough_response
}

data "template_file" "variables" {
  template = file("${path.module}/templates/variables.py.tpl")
  vars = {
    fallthrough = local.fallthrough
    host        = var.redirect_host
    redirects   = var.custom_redirects
  }
}

data "archive_file" "eastgardens" {
  type        = "zip"
  output_path = "eastgardens.zip"

  source {
    content  = file("${path.module}/src/eastgardens.py")
    filename = "eastgardens.py"
  }

  source {
    content  = data.template_file.variables.rendered
    filename = "variables.py"
  }
}

resource "aws_iam_role" "eastgardens" {
  path               = "/machine/"
  name               = "Eastgardens${var.namespace}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "edgelambda.amazonaws.com",
        "lambda.amazonaws.com",
      ]
    }

  }
}

resource "aws_iam_policy_attachment" "eastgardens" {
  name       = "EastgardensLogging${var.namespace}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.eastgardens.name]
}
