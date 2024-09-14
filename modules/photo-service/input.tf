variable "cf_acm_certificate_arn" {
  type = string
}

variable "cf_aliases" {
  type = list(string)
}

variable "cf_ordered_cache_cookies_forward" {
  description = "Ordered cache cookes forward"
  type        = string
  default     = "none"
}

variable "cf_ordered_cache_cookies_whitelisted_names" {
  description = "Ordered cache cookies whitelisted names"
  type        = list(string)
  default     = []
}

variable "cf_compress" {
  description = "Whether to compress cache"
  type        = bool
  default     = false
}

variable "cf_default_cache_allowed_methods" {
  description = "Cloudfront default cache allowed methods"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cf_default_cache_max_ttl" {
  description = "Cloudfront default cache max ttl"
  type        = string
  default     = "86400"
}

variable "cf_default_cache_default_ttl" {
  description = "Cloudfront default cache default ttl"
  type        = string
  default     = "14400"
}

variable "cf_default_cache_min_ttl" {
  description = "Cloudfront default cache min ttl"
  type        = string
  default     = "14400"
}

variable "cf_minimum_protocol_version" {
  description = "Cloudfront origin minimum protocol version"
  type        = string
  default     = "TLSv1.2_2019"
}

variable "cf_ordered_cache_allowed_methods" {
  description = "Cloudfront ordered cache allowed methods"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cf_ordered_cache_default_ttl" {
  description = "Cloudfront ordered cache default ttl"
  type        = string
  default     = "14400"
}

variable "cf_ordered_cache_headers" {
  description = "Cloudfront ordered cache headers"
  type        = list(string)
  default = [
    "Access-Control-Request-Headers",
    "Access-Control-Request-Method",
    "Origin",
    "Referer"
  ]
}

variable "cf_ordered_cache_max_ttl" {
  description = "Cloudfront ordered cache max ttl"
  type        = string
  default     = "86400"
}

variable "cf_ordered_cache_methods" {
  description = "Cloudfront ordered cache allowed methods"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cf_ordered_cache_min_ttl" {
  description = "Cloudfront ordered cache min ttl"
  type        = string
  default     = "14400"
}

variable "cf_ordered_cache_path_pattern" {
  description = "Cloudfront ordered cache path pattern"
  type        = string
  default     = "/photos/*"
}

variable "cf_origin_protocol_policy" {
  description = "Cloudfront origin protocol policy"
  type        = string
  default     = "https-only"
}

variable "cf_origin_custom_domain_name" {
  description = "Domain name of custom origin"
  type        = string
}

variable "cf_origin_access_identity_path" {
  type = string
}

variable "cf_web_acl_id" {
  type    = string
  default = null
}

variable "backend_serviceaccount_namespaces" {
  description = "K8s namespace for service account which will assume the role. https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html"
  type        = list(string)
  default     = []
}

variable "frontend_serviceaccount_namespaces" {
  description = "K8s namespace for service account which will assume the role. https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html"
  type        = list(string)
  default     = []
}

variable "k8s_provider_cluster_ca_certificate" {
  description = "Certificate for the back-end Kubernetes provider"
  type        = string
}

variable "k8s_provider_cluster_ca_certificate_public" {
  description = "Certificate for the front-end Kubernetes provider"
  type        = string
}

variable "k8s_provider_chost" {
  description = "chost for the back-end Kubernetes provider"
  type        = string
}

variable "k8s_provider_chost_public" {
  description = "chost for the front-enc Kubernetes provider"
  type        = string
}

variable "k8s_provider_ctoken" {
  description = "Token for the back-end Kubernetes provider"
  type        = string
}

variable "k8s_provider_ctoken_public" {
  description = "Token for the front-end Kubernetes provider"
  type        = string
}

variable "logging_config" {
  description = "Logging configuration"
  type        = any
  default     = null
}

variable "role_description" {
  description = "The AWS IAM role description"
  type        = string
  default     = "IAM Role to be used by AWS to access the S3 Bucket"
}

variable "role_description_public" {
  description = "The AWS IAM public role description"
  type        = string
  default     = "IAM Public Role to be used by AWS to access the Public S3 Bucket"
}

variable "role_name" {
  description = "The AWS IAM role name"
  type        = string
}

variable "role_name_public" {
  description = "The AWS IAM public role name"
  type        = string
}

variable "role_policy" {
  description = "The roles policy document"
  type        = string
  default     = ""
}

variable "role_policy_public" {
  description = "The public role's policy document"
  type        = string
  default     = ""
}

variable "s3_acl" {
  description = "(Optional) The canned ACL to apply. Conflicts with `grant`"
  type        = string
  default     = null # was "private". An S3 cannot have an ACL if object_ownership is set to BucketOwnerEnforced. Expect a aws_s3_bucket_acl to be destroyed.
}

variable "s3_bucket_name" {
  description = "The name of the bucket to store the archives (PDF files)"
  type        = string
}

variable "s3_bucket_name_public" {
  description = "The name of the public bucket to store the archives (PDF files)"
  type        = string
}

variable "s3_control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls on this bucket."
  type        = bool
  default     = true # now false in community module
}

variable "s3_object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter. 'BucketOwnerEnforced': ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket. 'BucketOwnerPreferred': Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL. 'ObjectWriter': The uploading account will own the object if the object is uploaded with the bucket-owner-full-control canned ACL."
  type        = string
  default     = "BucketOwnerEnforced" # Was "ObjectWriter". "BucketOwnerEnforced" is the new default in the community module. When using "BucketOwnerEnforced", no ACL is allowed.
}

variable "s3_public_bucket_policy" {
  description = "The policy of the public S3 bucket"
  type        = string
  default     = ""
}

variable "s3_server_side_encryption_configuration" {
  description = "Map containing server-side encryption configuration"
  type        = any
  default = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

variable "backup_tags" {
  description = "The backup tags to be associated with the resources"
  type        = map(string)
}

variable "tags" {
  description = "The tags to be associated with the resources"
  type        = map(string)
}

variable "trust_relationships" {
  description = "Trusted entities of the IAM role"
  type        = string
  default     = ""
}

variable "trust_relationships_public" {
  description = "Trusted entities of the IAM role"
  type        = string
  default     = ""
}

### Below won't be necessary when LPCA will support IRSA
variable "s3_iam_access_key_pgp" {
  description = "PGP key to encrypt the IAM access key"
  type    = string
  default = ""
}


variable "s3_photoservice_public_policy_name" {
  description = "The extra policy to access the public bucket"
  type        = string
  default     = ""
}