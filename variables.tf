variable "acm_certificate_arn" {
  description = "You'll need to provide a certificate for Cloudfront to use"
}

variable "artifacts_bucket" {
  description = "A pre-existing artifacts bucket that you like to use for storing build artifacts."
}

variable "custom_fallthrough_response" {
  description = "A custom response if no custom_redirects match. This should be a valid python object"
  default     = "None"
}

variable "custom_redirects" {
  description = "Your custom redirects"
  default     = "{}"
}

variable "hosts" {
  description = "The domains which would would like to redirect"
  type        = list
}

variable "minimum_protocol_version" {
  default = "TLSv1.2_2018"
}

variable "namespace" {
  description = "A simple unique namespace in case you need a few of these - used for roles etc"
  default     = "Eastgardens"
}

variable "redirect_host" {
  description = "Where to redirect to"
  default     = ""
}

variable "retain_on_delete" {
  description = "Enable this so that your runs don't fail due to the lambda@EDGE delete timing. You'll need to manually delete the distribution"
  default     = false
}

variable "ssl_support_method" {
  default = "sni-only"
}

variable "tags" {
  default = {}
}
