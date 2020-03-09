# A simple rick-rolling setup

provider "archive" {
  version = "~> 1.3"
}

provider "aws" {
  region  = "us-east-1"
  version = "~> 2.47"
}

provider "local" {
  version = "~> 1.4"
}

provider "random" {
  version = "~> 2.2"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_route53_zone" "marsupialmusic" {
  name = "marsupialmusic.net"
}

data "aws_acm_certificate" "wildcard" {
  domain   = "marsupialmusic.net"
  statuses = ["ISSUED"]
}

module "rick" {
  source = "../"

  namespace = "RickRolling"

  hosts = ["rick.marsupialmusic.net"]

  acm_certificate_arn         = data.aws_acm_certificate.wildcard.arn
  custom_fallthrough_response = <<DICT
{
    'status': '302',
    'statusDescription': 'Found',
    'headers': {
        'location': [{
            'key': 'Location',
            'value': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
        }]
    }
}
DICT

  artifacts_bucket = aws_s3_bucket.artifacts.bucket
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "eastgardens-test-lambda-artifacts"
}

resource "aws_route53_record" "rick" {
  zone_id = data.aws_route53_zone.marsupialmusic.zone_id
  type    = "CNAME"
  ttl     = "300"
  name    = "rick"

  records = [module.rick.cloudfront_distribution.domain_name]
}
