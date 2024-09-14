output "s3_bucket_id" {
  description = "The name of the bucket."
  value       = module.s3_cloudfront_stack.s3_bucket_id
}

output "s3_bucket_id_public" {
  description = "The name of the bucket."
  value       = module.s3_cloudfront_stack_public.s3_bucket_id
}

output "access_key_id_public" {
  value = module.iam_user_public.access_key_id
}

output "secret_key_id_public" {
  value = module.iam_user_public.secret_key_id
}
