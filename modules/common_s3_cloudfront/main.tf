locals {
  cloudfront_distribution_arn = module.cloudfront.cloudfront_distribution_arn

  s3_oac_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipalReadOnly",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.s3_bucket_name}${var.cf_origin_path}/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "${local.cloudfront_distribution_arn}"
                }
            }
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "combined" {
  source_policy_documents = compact([
    var.create_origin_access_control ? local.s3_oac_policy : "",
    var.s3_policy
  ])
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  acl                                  = var.s3_acl
  attach_policy                        = var.s3_attach_policy
  block_public_acls                    = var.s3_block_public_acls
  block_public_policy                  = var.s3_block_public_policy
  bucket                               = var.s3_bucket_name
  control_object_ownership             = var.s3_control_object_ownership
  cors_rule                            = var.s3_cors_rule
  ignore_public_acls                   = var.s3_ignore_public_acls
  lifecycle_rule                       = var.s3_lifecycle_rule
  # If you upgrade this module: object_ownership is a new param.
  # No need to import. tf apply. Expect a new ressource aws_s3_bucket_ownership_control.
  # "ObjectWriter" is the legacy value. "BucketOwnerEnforced" is the new AWS recommended value.
  object_lock_configuration            = var.s3_object_lock_configuration
  object_lock_enabled                  = var.s3_object_lock_enabled
  object_ownership                     = var.s3_object_ownership
  policy                               = data.aws_iam_policy_document.combined.json
  replication_configuration            = var.s3_replication_configuration
  restrict_public_buckets              = var.s3_restrict_public_buckets
  server_side_encryption_configuration = var.s3_server_side_encryption_configuration
  tags                                 = merge(var.tags, var.backup_tags)
  versioning                           = var.s3_versioning
  website                              = var.s3_website
}

module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.2.1"

  create_origin_access_control = var.create_origin_access_control
  origin_access_control = var.cf_origin_access_control

  create_origin_access_identity = var.create_origin_access_identity
  comment                       = var.cf_comment

  create_distribution = var.cf_create_distribution
  enabled             = var.cf_enabled

  aliases                       = var.cf_aliases
  custom_error_response         = var.cf_custom_error_response
  default_cache_behavior = {
    target_origin_id           = "S3-${var.s3_bucket_name}"
    viewer_protocol_policy     = var.cf_viewer_protocol_policy
    allowed_methods            = var.cf_allowed_methods
    cached_methods             = var.cf_cached_methods
    compress                   = var.cf_compress
    use_forwarded_values       = (var.cf_forward_headers != "" || var.cf_forward_query_string != "") ? true : false
    headers                    = var.cf_forward_headers
    query_string               = var.cf_forward_query_string
    min_ttl                    = var.cf_min_ttl
    max_ttl                    = var.cf_max_ttl
    default_ttl                = var.cf_default_ttl
    response_headers_policy_id = var.cf_response_headers_policy_id
  }
  default_root_object = var.cf_default_root_object
  geo_restriction     = var.cf_geo_restriction
  is_ipv6_enabled     = var.cf_is_ipv6_enabled
  logging_config      = length(var.cf_logs_bucket) == "" ? {} : {
    bucket = var.cf_logs_bucket
    prefix = var.cf_logs_prefix
  }

  origin = {
    "S3-${var.s3_bucket_name}" = {
      domain_name           = module.s3_bucket.s3_bucket_bucket_domain_name
      origin_path           = var.cf_origin_path
      origin_access_control = var.create_origin_access_control ? var.s3_bucket_name : ""

      s3_origin_config = var.create_origin_access_identity ? {
          cloudfront_access_identity_path = var.cf_origin_access_identity_path
      } : {}
    }
  }

  price_class      = var.cf_price_class
  retain_on_delete = false
  tags             = var.tags

  viewer_certificate = {
    acm_certificate_arn      = var.cf_acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = var.cf_minimum_tls
  }

  wait_for_deployment = var.cf_wait_for_deployment
  web_acl_id          = var.cf_web_acl_id
}
