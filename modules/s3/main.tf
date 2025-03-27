resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(var.common_tags, {
    sd_Name = "sd-graph-db-poc-kms-key"
  })
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/sd-graph-db-poc-s3-key"
  target_key_id = aws_kms_key.s3_key.key_id
}

resource "aws_s3_bucket" "graph_db_poc" {
  bucket        = "sd-graph-db-poc-${data.aws_caller_identity.current.account_id}"
  force_destroy = true  # Add this line to enable force delete

  tags = merge(var.common_tags, {
    sd_Name = "sd-graph-db-poc"
  })
}

resource "aws_s3_bucket_versioning" "graph_db_poc" {
  bucket = aws_s3_bucket.graph_db_poc.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "graph_db_poc" {
  bucket = aws_s3_bucket.graph_db_poc.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "graph_db_poc" {
  bucket = aws_s3_bucket.graph_db_poc.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = var.private_route_table_ids

  tags = merge(var.common_tags, {
    sd_Name = "sd-s3-vpc-endpoint"
  })
}

# CloudWatch Log Group for S3 Access Logs
resource "aws_cloudwatch_log_group" "s3_access" {
  name              = "/sd/s3/graph-db-poc-access"
  retention_in_days = 30

  tags = merge(var.common_tags, {
    sd_Name = "sd-graph-db-poc-s3-access-logs"
  })
}

# Update bucket to enable logging
resource "aws_s3_bucket_logging" "graph_db_poc" {
  bucket = aws_s3_bucket.graph_db_poc.id

  target_bucket = aws_s3_bucket.graph_db_poc.id
  target_prefix = "logs/"
}


data "aws_caller_identity" "current" {}

