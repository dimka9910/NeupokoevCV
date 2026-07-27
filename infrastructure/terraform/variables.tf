variable "region" {
  description = "Primary AWS region for non-CloudFront resources"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Short project name used as a resource/tag prefix"
  type        = string
  default     = "neupokoevcv"
}

variable "domain_name" {
  description = "Root domain for the CV site"
  type        = string
  default     = "neupokoev.cv"
}

variable "extra_tags" {
  description = "Additional tags merged into every resource"
  type        = map(string)
  default     = {}
}
