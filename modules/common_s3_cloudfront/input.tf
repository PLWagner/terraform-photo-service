variable "cf_create_distribution" {
  description = "Controls if CloudFront distribution should be created"
  type        = bool
  default     = true
}

variable "cf_acm_certificate_arn" {
  type    = string
  default = null
}

variable "cf_enabled" {
  type    = bool
  default = true
}

variable "cf_aliases" {
  type    = list(string)
  default = null
}

variable "cf_allowed_methods" {
  type    = list(string)
  default = ["GET", "HEAD", "OPTIONS"]
}

variable "cf_cached_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

variable "cf_comment" {
  description = "Any comments you want to include about the distribution."
  type        = string
  default     = null
}

variable "cf_compress" {
  type    = bool
  default = true
}

variable "cf_custom_error_response" {
  description = "One or more custom error response elements"
  type        = any
  default     = {}
}

variable "cf_default_root_object" {
  type    = string
  default = null
}

variable "cf_default_ttl" {
  type    = number
  default = null
}

variable "cf_forward_headers" {
  description = "Specifies the Headers, if any, that you want CloudFront to vary upon for this cache behavior. Specify * to include all headers."
  type        = list(string)
  default     = []
}

variable "cf_forward_query_string" {
  description = "Indicates whether you want CloudFront to forward query strings to the origin that is associated with this cache behavior."
  type        = bool
  default     = false
}

variable "cf_geo_restriction" {
  type    = any
  default = {}
}

variable "cf_is_ipv6_enabled" {
  type    = bool
  default = false
}

variable "cf_logs_bucket" {
  type    = string
  default = ""
}

variable "cf_logs_prefix" {
  type    = string
  default = ""
}

variable "cf_max_ttl" {
  type    = number
  default = null
}

variable "cf_min_ttl" {
  type    = number
  default = null
}

variable "cf_minimum_tls" {
  type    = string
  default = "TLSv1.2_2019"
}

variable "cf_origin_access_control" {
  description = "Map of CloudFront origin access control"
  type = map(object({
    description      = string
    origin_type      = string
    signing_behavior = string
    signing_protocol = string
  }))

  default = {
    s3 = {
      description      = "",
      origin_type      = "s3",
      signing_behavior = "always",
      signing_protocol = "sigv4"
    }
  }
}

variable "cf_origin" {
  description = "One or more origins for this distribution (multiples allowed)."
  type        = any
  default     = null
}

variable "cf_origin_path" {
  type    = string
  default = ""
}

variable "cf_origin_access_identity_path" {
  type    = string
  default = ""
}

variable "cf_origin_access_identity_comment" {
  type    = string
  default = null
}

variable "cf_price_class" {
  type    = string
  default = "PriceClass_100"
}

# For preset values: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html
variable "cf_response_headers_policy_id" {
  type    = string
  default = null
}

variable "cf_viewer_protocol_policy" {
  type    = string
  default = "redirect-to-https"
}

variable "cf_wait_for_deployment" {
  description = "If enabled, the resource will wait for the distribution status to change from InProgress to Deployed. Setting this tofalse will skip the process."
  type        = bool
  default     = true
}

variable "cf_web_acl_id" {
  description = "If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution. The WAF Web ACL must exist in the WAF Global (CloudFront) region and the credentials configuring this argument must have waf:GetWebACL permissions assigned. If using WAFv2, provide the ARN of the web ACL."
  type        = string
  default     = null
}

variable "create_origin_access_identity" {
  description = "Controls if CloudFront origin access identity should be created"
  type        = bool
  default     = true
}

variable "create_origin_access_control" {
  description = "Controls if CloudFront origin access control should be created"
  type        = bool
  default     = false
}

variable "s3_acl" {
  description = "(Optional) The canned ACL to apply. Conflicts with `grant`"
  type        = string
  default     = "private" # was "null". An S3 cannot have an ACL if object_ownership is set to BucketOwnerEnforced. To allow ACL, you require bucket ownership set to Bucket Writer. Otherwise, Expect a aws_s3_bucket_acl to be destroyed.
}

variable "s3_block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "s3_block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "The name of the bucket to store the archives (PDF files)"
  type        = string
}

variable "s3_control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls on this bucket."
  type        = bool
  default     = true # now false in community module
}

variable "s3_cors_rule" {
  description = "List of maps containing rules for Cross-Origin Resource Sharing."
  type        = any
  default     = []
}

variable "s3_iam_policy_name_override" {
  type    = string
  default = ""
}

variable "s3_iam_user_enabled" {
  type    = bool
  default = false
}

variable "s3_iam_user_name_override" {
  type    = string
  default = ""
}

variable "s3_ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "s3_lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "s3_object_lock_configuration" {
  description = "Map containing S3 object locking configuration."
  type        = any
  default = {}
}

variable "s3_object_lock_enabled" {
  description = "Whether S3 bucket should have an Object Lock configuration enabled."
  type        = bool
  default     = false
}

variable "s3_object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter. 'BucketOwnerEnforced': ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket. 'BucketOwnerPreferred': Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL. 'ObjectWriter': The uploading account will own the object if the object is uploaded with the bucket-owner-full-control canned ACL."
  type        = string
  default     = "ObjectWriter" # "BucketOwnerEnforced" is the new default in the community module. When using "BucketOwnerEnforced", no ACL is allowed.
}

variable "s3_policy" {
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
  type        = string
  default     = null
}

variable "s3_replication_configuration" {
  description = "Map containing cross-region replication configuration."
  type        = any
  default     = {}
}

variable "s3_restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "s3_server_side_encryption_configuration" {
  description = "Map containing server-side encryption configuration."
  type        = any
  default = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

variable "s3_versioning" {
  description = "Map containing versioning configuration."
  type        = map(string)
  default     = {}
}

variable "s3_website" {
  description = "Map containing static web-site hosting or redirect configuration."
  type        = map(string)
  default     = {}
}

variable "s3_attach_policy" {
  description = "Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy)"
  type        = bool
  default     = true
}

variable "backup_tags" {
  description = "The backup tags to be associated with the resources"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "The tags to be associated with the resources"
  type        = map(string)
}
