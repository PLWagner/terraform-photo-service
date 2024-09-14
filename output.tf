output "s3_bucket_id" {
  description = "The name of the bucket."
  value       = module.photo-service.s3_bucket_id
}

output "s3_bucket_id_public" {
  description = "The name of the bucket."
  value       = module.photo-service.s3_bucket_id_public
}

output "access_key_id_public" {
  description = "The access_key_id of the IAM user."
  value       = module.photo-service.access_key_id_public
}

output "secret_key_id_public" {
  description = "The secret_key_id of the IAM user."
  value       = module.photo-service.secret_key_id_public
}

