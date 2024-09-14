locals {
  frontend_serviceaccount_namespaces = ["valid-1", "valid-2", "valid-3", "valid-master"]
  backend_serviceaccount_namespaces  = ["valid-1", "valid-2", "valid-3", "valid-master"]
  bucket_name                        = "dev-photo-service-2"
  bucket_name_public                 = "dev-photo-service-public-2"
  cf_acm_certificate_arn             = "arn:aws:acm:us-east-1:123456789101:certificate/9eddxxxx-xxxx-xxxx-xxxx-40b903a1c4d5"
  cf_compress                        = true
  cf_default_cache_default_ttl       = 0
  cf_default_cache_max_ttl           = 0
  cf_default_cache_min_ttl           = 0
  cf_minimum_protocol_version        = "TLSv1.2_2021"

  cf_ordered_cache_allowed_methods           = ["GET", "HEAD", "OPTIONS"]
  cf_ordered_cache_cookies_forward           = "whitelist"
  cf_ordered_cache_cookies_whitelisted_names = ["aws-waf-token"]
  cf_ordered_cache_default_ttl               = 3600

  cf_ordered_cache_headers = [
    "Access-Control-Request-Headers",
    "Access-Control-Request-Method",
    "Origin",
    "Referer",
    "Host"
  ]

  cf_ordered_cache_max_ttl          = 86400
  cf_ordered_cache_min_ttl          = 0
  cf_ordered_cache_path_pattern     = "/*/photos/*"
  cf_origin_access_identity_comment = "dev-photo-service-public-2 dev-photo-service-public-2.s3.amazonaws.com"
  cf_origin_custom_domain_name      = "dev-fe.us-east-1.elb.amazonaws.com"
  cf_origin_protocol_policy         = "match-viewer"
  cf_web_acl_id                     = "arn:aws:wafv2:us-east-1:123456789101:global/webacl/cloudfront-waf-non-public-access/2besdfsd-xxxx-xxxx-xxxx-3cc304f35dc4"
  hostnames                         = ["images.rb-fe.dev.patate.poil"]
  iam_oidc_provider                 = data.terraform_remote_state.eks_dev_be.outputs.oidc_provider
  iam_oidc_provider_arn             = data.terraform_remote_state.eks_dev_be.outputs.oidc_provider_arn
  iam_oidc_provider_public          = data.terraform_remote_state.eks_dev_fe.outputs.oidc_provider
  iam_oidc_provider_arn_public      = data.terraform_remote_state.eks_dev_fe.outputs.oidc_provider_arn
  photoservice_public_policy_name   = "dev_photoservice_public_s3_user_policy" # Will be delete when LPCA is going to support IRSA
  role_name                         = "photo-service"
  role_name_public                  = "photo-service-public"
  s3_block_public_acls_public       = true
  s3_block_public_policy_public     = true
  s3_ignore_public_acls_public      = true

  backup_tags = {
    BackupIntervalAndRetention = "Disabled"
  }

  tags = {
    Application = "rb-photo-service",
    Environment = "development",
    Jira        = "EXPL-3270:ARC-130",
    ManagedBy   = "tsv/environments/development/photo-service",
    Teams       = "Rubicon:Arcadia",
  }
}

data "aws_eks_cluster_auth" "dev_be" {
  name = "dev-be"
}

data "aws_eks_cluster_auth" "dev_fe" {
  name = "dev-fe"
}

data "terraform_remote_state" "eks_dev_be" {
  backend = "s3"
  config = {
    bucket = "tfstate"
    key    = "tsv/accounts/development/eks-dev-be"
    region = "us-east-1"
    assume_role = {
      role_arn = "arn:aws:iam::123456789101:role/tfstate-bucket-access"
    }
  }
}

data "terraform_remote_state" "eks_dev_fe" {
  backend = "s3"
  config = {
    bucket = "tfstate"
    key    = "tsv/accounts/development/eks-dev-fe"
    region = "us-east-1"
    assume_role = {
      role_arn = "arn:aws:iam::123456789101:role/tfstate-bucket-access"
    }
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
      "arn:aws:s3:::${local.bucket_name}/*",
      "arn:aws:s3:::${local.bucket_name_public}",
      "arn:aws:s3:::${local.bucket_name_public}/*"
    ]
  }
}

data "aws_iam_policy_document" "policy_public" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject", # only for path cache
      "s3:PutObjectAcl" # only for path cache
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name_public}",
      "arn:aws:s3:::${local.bucket_name_public}/*"
    ]
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = local.cf_origin_access_identity_comment
}

module "photo-service" {
  source = "./modules/photo-service"

  cf_acm_certificate_arn                     = local.cf_acm_certificate_arn
  cf_aliases                                 = local.hostnames
  cf_origin_access_identity_path             = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
  cf_origin_custom_domain_name               = local.cf_origin_custom_domain_name
  cf_origin_protocol_policy                  = local.cf_origin_protocol_policy
  cf_web_acl_id                              = local.cf_web_acl_id
  frontend_serviceaccount_namespaces         = local.frontend_serviceaccount_namespaces
  backend_serviceaccount_namespaces          = local.backend_serviceaccount_namespaces
  k8s_provider_cluster_ca_certificate        = base64decode(data.terraform_remote_state.eks_dev_be.outputs.cluster_certificate_authority_data)
  k8s_provider_cluster_ca_certificate_public = base64decode(data.terraform_remote_state.eks_dev_fe.outputs.cluster_certificate_authority_data)
  k8s_provider_chost                         = data.terraform_remote_state.eks_dev_be.outputs.cluster_endpoint
  k8s_provider_chost_public                  = data.terraform_remote_state.eks_dev_fe.outputs.cluster_endpoint
  k8s_provider_ctoken                        = data.aws_eks_cluster_auth.dev_be.token
  k8s_provider_ctoken_public                 = data.aws_eks_cluster_auth.dev_fe.token
  logging_config                             = {
    bucket = "cloudfront-logs.s3.amazonaws.com"
    prefix = "images.rb-fe.dev.patate.poil"
  }

  role_name                                  = local.role_name
  role_name_public                           = local.role_name_public
  role_policy                                = data.aws_iam_policy_document.policy.json
  role_policy_public                         = data.aws_iam_policy_document.policy_public.json

  s3_acl                                     = "private"
  s3_control_object_ownership                = true
  s3_object_ownership                        = "ObjectWriter"

  s3_bucket_name                             = local.bucket_name
  s3_bucket_name_public                      = local.bucket_name_public
  # s3_iam_access_key_pgp                      = module.env.pgp_key_D34270FA
  s3_photoservice_public_policy_name         = local.photoservice_public_policy_name

  s3_public_bucket_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront_Origin_Access_Identity_${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${local.bucket_name_public}/*"
        },
        {
            "Sid": "DisableBucketDeletion",
            "Effect": "Deny",
            "Principal": "*",
            "Action": [
                "s3:DeleteBucket",
                "s3:DeleteBucketPolicy"
            ],
            "Resource": "arn:aws:s3:::${local.bucket_name_public}"
        },
        {
            "Sid": "AllowSSLRequestsOnly",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${local.bucket_name_public}",
                "arn:aws:s3:::${local.bucket_name_public}/*"
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

  trust_relationships = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${local.iam_oidc_provider_arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "${local.iam_oidc_provider}:aud": "sts.amazonaws.com",
                    "${local.iam_oidc_provider}:sub": "system:serviceaccount:*:photo-service"
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${local.iam_oidc_provider_arn_public}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "${local.iam_oidc_provider_public}:aud": "sts.amazonaws.com",
                    "${local.iam_oidc_provider_public}:sub": "system:serviceaccount:*:photo-service"
                }
            }
        }
    ]
}
EOF

  trust_relationships_public = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${local.iam_oidc_provider_arn_public}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "${local.iam_oidc_provider_public}:aud": "sts.amazonaws.com",
                    "${local.iam_oidc_provider_public}:sub": "system:serviceaccount:*:photo-service"
                }
            }
        }
    ]
}
EOF

  tags                              = local.tags
  backup_tags                       = local.backup_tags
}
