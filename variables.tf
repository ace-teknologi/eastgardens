variable "acm_certificate_arn" {
  description = "You'll need to provide a certificate for Cloudfront to use"
}

variable "custom_fallthrough_response" {
  description = "A custom response if no custom_redirects match"
  default     = ""
}

variable "custom_redirects" {
  description = "Your custom redirects"
  default     = ""
}

variable "host" {
  description = "The domain which would would like to redirect"
}

variable "minimum_protocol_version" {
  default = "TLSv1.2_2018"
}

variable "redirect_host" {
  description = "Where to redirect to"
  default     = ""
}

variable "ssl_support_method" {
  default = "sni-only"
}
