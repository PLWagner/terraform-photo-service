module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.2.1"

  aliases                       = var.aliases
  comment                       = var.comment
  create_origin_access_identity = var.create_origin_access_identity
  default_cache_behavior        = var.default_cache_behavior
  default_root_object           = var.default_root_object
  enabled                       = var.enabled
  geo_restriction               = var.geo_restriction
  is_ipv6_enabled               = var.is_ipv6_enabled
  logging_config                = var.logging_config
  ordered_cache_behavior        = var.ordered_cache_behavior
  origin                        = var.origin
  origin_access_identities      = var.origin_access_identities
  price_class                   = var.price_class
  retain_on_delete              = var.retain_on_delete
  viewer_certificate            = var.viewer_certificate
  wait_for_deployment           = var.wait_for_deployment
  web_acl_id                    = var.web_acl_id

  tags = var.tags
}
