# Eastgardens

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
  source = "git::ssh://git@github.com/ace-teknologi/eastgardens?ref=v0.0.1

  host = "www.mygreatwebsite.com"
  redirect_host = "mygreatwebsite.com"
  acm_certificate_arn = aws_acm_certificate_validation.my_cert.arn
}
```

### Trickier use case - redirect a whole bunch of specific endpoints

```hcl2
module "endpoint_redirect" {
  source = "git::ssh://git@github.com/ace-teknologi/eastgardens?ref=v0.0.1

  host = "my-old-website.com"
  redirect_host = "my-new-website.com"

  custom_redirects = <<EOF
  '/stupid-additional-app-that-my-server-used-to-run': 'https://my-new-app.com/',
  '/weird-custom-shit/page1': 'https://new-app.com/1'
  EOF
  acm_certificate_arn = aws_acm_certificate_validation.my_cert.arn
}



