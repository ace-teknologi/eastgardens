provider "archive" {
  version = "~> 1.3"
}

provider "aws" {
  # Because this is Cloudfront-driven, everything must be in N. Virginia
  region  = "us-east-1"
  version = "~> 2.47"
}

provider "template" {
  version = "~> 2.1"
}