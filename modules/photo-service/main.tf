module "s3_cloudfront_stack" {
  source = "../common_s3_cloudfront"

  cf_create_distribution = false
  s3_bucket_name         = var.s3_bucket_name
  s3_lifecycle_rule = [
    {
      enabled = true
      id      = "expire_path"
      expiration = {
        days                         = 7
        expired_object_delete_marker = false
      }
      filter = {
        prefix = "/cache"
      }
      noncurrent_version_expiration = {
        noncurrent_days = 7
      }
    },
    {
      enabled = false
      id      = "transition_lifecycle"
      transition = {
        days          = 30
        storage_class = "GLACIER"
      }
    },
    {
      enabled = true
      id      = "noncurrent_expiration"
      status  = "Enabled"
      filter = {
      }
      noncurrent_version_expiration = {
        noncurrent_days = 90
      }
    }
  ]

  s3_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DisableBucketDeletion",
            "Effect": "Deny",
            "Principal": "*",
            "Action": [
                "s3:DeleteBucket",
                "s3:DeleteBucketPolicy"
            ],
            "Resource": "arn:aws:s3:::${var.s3_bucket_name}"
        },
        {
            "Sid": "AllowSSLRequestsOnly",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket_name}",
                "arn:aws:s3:::${var.s3_bucket_name}/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
EOF

  s3_control_object_ownership             = var.s3_control_object_ownership
  s3_object_ownership                     = var.s3_object_ownership
  s3_acl                                  = var.s3_acl
  s3_server_side_encryption_configuration = var.s3_server_side_encryption_configuration

  s3_versioning = {
    status     = true
    mfa_delete = false
  }

  backup_tags = var.backup_tags
  tags        = var.tags
}

# On ne doit pas bloquer ou restreindre l'accès public avec les checkboxes de S3. Il y a un enjeu qui reste à éclaircir avec le
# service qui roule dans le compte LP+ Prod et utilisant le user du compte App Mobile Prod. Si on active les checkboxes, on a
# des erreurs 403.
module "s3_cloudfront_stack_public" {
  source = "../common_s3_cloudfront"

  cf_create_distribution = false
  s3_bucket_name         = var.s3_bucket_name_public

  s3_lifecycle_rule = [
    {
      id      = "lifecycle-noncurrent-version"
      enabled = false

      noncurrent_version_expiration = {
        noncurrent_days = 90
      }
    },
    {
      id      = "lifecycle-deletion-rule"
      enabled = false

      expiration = {
        days                         = 365
        expired_object_delete_marker = false
      }
    },
  ]

  s3_control_object_ownership             = var.s3_control_object_ownership
  s3_object_ownership                     = var.s3_object_ownership
  s3_acl                                  = var.s3_acl
  s3_policy                               = var.s3_public_bucket_policy
  s3_server_side_encryption_configuration = var.s3_server_side_encryption_configuration

  s3_versioning = {
    mfa_delete = "Disabled"
    status     = "Enabled"
  }

  backup_tags = var.backup_tags
  tags        = var.tags
}

module "common_cloudfront" {
  source = "../common_cloudfront"

  aliases = var.cf_aliases

  logging_config = var.logging_config

  default_cache_behavior = {
    allowed_methods = var.cf_default_cache_allowed_methods
    cached_methods  = var.cf_default_cache_allowed_methods
    compress        = var.cf_compress
    default_ttl     = var.cf_default_cache_default_ttl

    headers = [
      "Access-Control-Request-Headers",
      "Access-Control-Request-Method",
      "Origin",
    ]

    max_ttl                = var.cf_default_cache_max_ttl
    min_ttl                = var.cf_default_cache_min_ttl
    query_string           = true
    target_origin_id       = "S3-${var.s3_bucket_name_public}"
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior = [
    {
      allowed_methods           = var.cf_ordered_cache_allowed_methods
      cached_methods            = var.cf_ordered_cache_methods
      cookies_forward           = var.cf_ordered_cache_cookies_forward
      cookies_whitelisted_names = var.cf_ordered_cache_cookies_whitelisted_names
      compress                  = var.cf_compress
      default_ttl               = var.cf_ordered_cache_default_ttl
      headers                   = var.cf_ordered_cache_headers
      max_ttl                   = var.cf_ordered_cache_max_ttl
      min_ttl                   = var.cf_ordered_cache_min_ttl
      path_pattern              = var.cf_ordered_cache_path_pattern
      query_string              = true
      target_origin_id          = var.cf_origin_custom_domain_name
      viewer_protocol_policy    = "redirect-to-https"
    }
  ]

  origin = {
    (var.cf_origin_custom_domain_name) = {
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = var.cf_origin_protocol_policy
        origin_ssl_protocols   = ["TLSv1.2"]
      }

      domain_name = var.cf_origin_custom_domain_name
    }

    "S3-${var.s3_bucket_name_public}" = {
      domain_name = "${var.s3_bucket_name_public}.s3.amazonaws.com"

      s3_origin_config = {
        cloudfront_access_identity_path = var.cf_origin_access_identity_path
      }
    }
  }

  price_class = "PriceClass_100"
  tags        = var.tags

  viewer_certificate = {
    acm_certificate_arn      = var.cf_acm_certificate_arn
    minimum_protocol_version = var.cf_minimum_protocol_version
    ssl_support_method       = "sni-only"
  }

  web_acl_id = var.cf_web_acl_id
}

resource "aws_iam_policy" "photo_service" {
  name   = var.role_name
  policy = var.role_policy
  tags   = var.tags
}

resource "aws_iam_policy" "photo_service_public" {
  name   = var.role_name_public
  policy = var.role_policy_public
  tags   = var.tags
}

resource "aws_iam_role" "photo_service" {
  assume_role_policy = var.trust_relationships
  name               = var.role_name
  description        = var.role_description
  tags               = var.tags
}

resource "aws_iam_role" "photo_service_public" {
  assume_role_policy = var.trust_relationships_public
  name               = var.role_name_public
  description        = var.role_description_public
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "photo_service" {
  role       = aws_iam_role.photo_service.id
  policy_arn = aws_iam_policy.photo_service.arn
}

resource "aws_iam_role_policy_attachment" "photo_service_public" {
  role       = aws_iam_role.photo_service_public.id
  policy_arn = aws_iam_policy.photo_service_public.arn
}

resource "kubernetes_service_account" "photo_service_account" {
  for_each = toset(var.backend_serviceaccount_namespaces)
  provider = kubernetes.backend

  metadata {
    name      = "photo-service"
    namespace = each.value

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.photo_service.arn
    }
  }

  image_pull_secret {
    name = "docker-registry-creds"
  }
}

resource "kubernetes_service_account" "photo_service_account_public" {
  for_each = toset(var.frontend_serviceaccount_namespaces)
  provider = kubernetes.frontend

  metadata {
    name      = "photo-service"
    namespace = each.value

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.photo_service_public.arn
    }
  }

  image_pull_secret {
    name = "docker-registry-creds"
  }
}

# Should be evantually deleted, but for now, we need to keep it for the photo-service-public to work. Poke Dock Troopers to support IRSA.
module "iam_user_public" {
  source = "../common_s3_iam_user"

  s3_bucket_name        = var.s3_bucket_name_public
  s3_iam_access_key_pgp = var.s3_iam_access_key_pgp
  tags                  = var.tags
}

data "aws_iam_policy_document" "rb_photoservice_s3_user_policy" {
  statement {
    sid = "AllowAccessToRBProdPhotoSrvS3"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name_public}",
      "arn:aws:s3:::${var.s3_bucket_name_public}/*",
    ]
  }
}

resource "aws_iam_policy" "rb_photoservice_s3_user_policy" {
  name   = var.s3_photoservice_public_policy_name
  policy = data.aws_iam_policy_document.rb_photoservice_s3_user_policy.json
}

resource "aws_iam_user_policy_attachment" "rb_photoservice_s3_user_policy_attachment" {
  policy_arn = aws_iam_policy.rb_photoservice_s3_user_policy.arn
  user       = "${var.s3_bucket_name}_user"
}
