variable "region" {
  type        = string
  description = "The AWS Region"
}

variable "provider_allowed_account_ids" {
  type        = list(string)
  description = "The AWS Providers allowed account ids"
}

variable "provider_assume_role_role_arn" {
  type        = string
  description = "The AWS Providers role ARN to assume"
}
