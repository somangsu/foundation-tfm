output "bucket_name" {
  value = aws_s3_bucket.graph_db_poc.id
}

output "bucket_arn" {
  value = aws_s3_bucket.graph_db_poc.arn
}

output "kms_key_arn" {
  value = aws_kms_key.s3_key.arn
}
