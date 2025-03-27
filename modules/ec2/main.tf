

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "sd-graph-db-poc-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# Add AmazonSSMManagedInstanceCore policy
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:${var.cloud_partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# S3 and KMS access policy
resource "aws_iam_role_policy" "s3_access" {
  name = "sd-graph-db-poc-s3-access"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"  # Allows all S3 actions
        ]
        Resource = [
          "arn:${var.cloud_partition}:s3:::*",  # All buckets
          "arn:${var.cloud_partition}:s3:::*/*" # All objects in all buckets
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:ListAliases"
        ]
        Resource = [
          var.kms_key_arn,
          "*"  # Allow access to all KMS keys (optional, remove if you want to restrict to specific keys)
        ]
      }
    ]
  })
}

# Optional: Add S3 list buckets policy
resource "aws_iam_role_policy" "s3_list" {
  name = "sd-graph-db-poc-s3-list"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:GetAccountPublicAccessBlock",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetBucketPolicyStatus",
          "s3:GetBucketAcl",
          "s3:ListAccessPoints"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "sd-graph-db-poc-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "sd-graph-db-poc-ec2-sg"
  description = "Security group for Graph DB POC EC2 instance"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    sd_Name = "sd-graph-db-poc-ec2-sg"
  })
}

# VPC Endpoints for SSM
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnet_id]
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    sd_Name = "sd-ssm-vpc-endpoint"
  })
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnet_id]
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    sd_Name = "sd-ssmmessages-vpc-endpoint"
  })
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnet_id]
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    sd_Name = "sd-ec2messages-vpc-endpoint"
  })
}

# Security Group for VPC Endpoints
resource "aws_security_group" "vpce_sg" {
  name        = "sd-graph-db-poc-vpce-sg"
  description = "Security group for SSM VPC Endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  tags = merge(var.common_tags, {
    sd_Name = "sd-graph-db-poc-vpce-sg"
  })
}

# EC2 Instance
resource "aws_instance" "graph_db_poc" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  root_block_device {
    volume_size = 30
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # IMDSv2 required
  }

  tags = merge(var.common_tags, {
    sd_Name = "sd-graph-db-poc-ec2"
  })
}

# Add CloudWatch Logs policy
resource "aws_iam_role_policy" "cloudwatch_logs" {
  name = "sd-graph-db-poc-cloudwatch-logs"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

# VPC Endpoint for CloudWatch Logs
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subnet_id]
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    sd_Name = "sd-cloudwatch-logs-vpc-endpoint"
  })
}

# CloudWatch Log Group for EC2
resource "aws_cloudwatch_log_group" "ec2" {
  name              = "/sd/ec2/graph-db-poc"
  retention_in_days = 30

  tags = merge(var.common_tags, {
    sd_Name = "sd-graph-db-poc-ec2-logs"
  })
}
