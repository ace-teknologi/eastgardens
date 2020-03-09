# Eastgardens

[![Maintainability](https://api.codeclimate.com/v1/badges/63bda21becce93053241/maintainability)](https://codeclimate.com/github/ace-teknologi/eastgardens/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/63bda21becce93053241/test_coverage)](https://codeclimate.com/github/ace-teknologi/eastgardens/test_coverage)

![Found](./302.jpg)

A Cloudfront / Lambda@Edge setup to redirect HTTP requests.

## Advice

This module is not stable. If you are going to use it, please use version
control. Also, lambda@edge functions are really difficult to delete, so be
patient if you update the module.

## Usage

### Basic use case - redirect www to the apex of your domain

```hcl2
module "www_redirect" {
  source = "git::ssh://git@github.com/ace-teknologi/eastgardens?ref=v0.3.0"

  namespace = "MyGreatWebsite"

  hosts               = ["www.mygreatwebsite.com"]
  redirect_host       = "mygreatwebsite.com"
  acm_certificate_arn = aws_acm_certificate_validation.my_cert.arn

  artifacts_bucket = "my-great-bucket-for-building-things"
}
```

### Trickier use case - redirect a whole bunch of specific endpoints

```hcl2
module "endpoint_redirect" {
  source = "git::ssh://git@github.com/ace-teknologi/eastgardens?ref=v0.3.0"

  namespace = "MyNewWebsite"

  hosts         = ["my-old-website.com", "prod.my-old-website.com"]
  redirect_host = "my-new-website.com"

  # Note: custom_redirects must be a python dict for now
  custom_redirects = <<EOF
  {
    '/stupid-additional-app-that-my-server-used-to-run': 'https://my-new-app.com/',
    '/weird-custom-shit/page1': 'https://new-app.com/1'
  }
  EOF
  acm_certificate_arn = aws_acm_certificate_validation.my_cert.arn

  artifacts_bucket = "my-great-bucket-for-building-things"
}


### Expire most of your old content but save a few select links
```hcl2
module "limited_redirect" {
  source = "git::ssh://git@github.com/ace-teknologi/eastgardens?ref=v0.3.0"

  namespace = "MyNewWithOldStuffWebsite"

  providers = {
    aws = "aws.us-east-1"
  }

  hosts            = ["my.old.website"]
  custom_redirects = <<EOF
  {
    '/content/that-i-need': 'https://my.new.website.com/this-is-my-link'
  }
  EOF

  custom_fallthrough_response = <<EOF
  {
        'status': '410',
        'statusDescription': 'Gone',
        'headers': {
            'content-type': [{
                'key': 'Content-Type',
                'value': 'text/html'
            }]
        },
        'body': """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <title>This content is gone</title>
        </head>
        <body>
          <p>This content is gone</p>
        </body>
        </html>
        """
    }
  EOF

  acm_certificate_arn = data.aws_acm_certificate.my_cert.arn

  artifacts_bucket = "my-great-bucket-for-building-things"
}
```
