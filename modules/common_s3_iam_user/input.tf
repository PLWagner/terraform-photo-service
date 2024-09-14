variable "cf_cloudfront_distribution_arn" {
  type    = string
  default = ""
}

variable "cf_policy_actions" {
  type = list(string)
  default = [
    "cloudfront:CreateInvalidation",
    "cloudfront:GetDistribution",
  ]
}

variable "s3_bucket_name" {
  description = "The name of the bucket to store the archives (PDF files)"
  type        = string
}

variable "s3_iam_access_key_pgp" {
  type = string
}

variable "s3_policy_actions" {
  type = list(string)
  default = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:DeleteObject",
    "s3:ListBucket",
  ]
}

variable "ses_policy" {
  description = "(Optional) A valid ses policy JSON document to attach to iam user."
  type        = string
  default     = null
}

variable "ses_policy_enabled" {
  description = "(Optional) Create or not ses policy."
  type        = bool
  default     = false
}

variable "tags" {
  description = "The tags to be associated with the resources"
  type        = map(string)
}
