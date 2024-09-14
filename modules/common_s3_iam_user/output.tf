output "access_key_id" {
  value = aws_iam_access_key.bucket_user_key.id
}

output "secret_key_id" {
  value = aws_iam_access_key.bucket_user_key.encrypted_secret
}
