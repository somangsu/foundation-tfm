

# Neptune Cluster
resource "aws_neptune_cluster" "graph_db" {
  cluster_identifier                  = "sd-graph-db-poc"
  engine                             = "neptune"
  engine_version                     = "1.2.1.0"
  serverless_v2_scaling_configuration {
    min_capacity = 1.0
    max_capacity = 8.0
  }
  vpc_security_group_ids             = [aws_security_group.neptune_sg.id]
  neptune_subnet_group_name         = aws_neptune_subnet_group.graph_db.name  # Fixed attribute name
  skip_final_snapshot               = true
  iam_database_authentication_enabled = true
  apply_immediately                 = true

  tags = merge(var.common_tags, {
    sd_Name = "sd-graph-db-poc-neptune"
  })
}

# Neptune Instance
resource "aws_neptune_cluster_instance" "graph_db" {
  count               = 1
  cluster_identifier = aws_neptune_cluster.graph_db.id
  instance_class     = "db.serverless"
  engine             = "neptune"
  
  tags = merge(var.common_tags, {
    sd_Name = "sd-graph-db-poc-neptune-instance"
  })
}

# Neptune Subnet Group
resource "aws_neptune_subnet_group" "graph_db" {
  name       = "sd-graph-db-poc-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.common_tags, {
    sd_Name = "sd-graph-db-poc-subnet-group"
  })
}

# Rest of the configuration remains the same...


# Security Group for Neptune
# Update Neptune Security Group
resource "aws_security_group" "neptune_sg" {
  name        = "sd-graph-db-poc-neptune-sg"
  description = "Security group for Neptune database"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8182
    to_port         = 8182
    protocol        = "tcp"
    security_groups = [aws_security_group.sagemaker_sg.id]
  }

  # Add egress rule if needed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    sd_Name = "sd-graph-db-poc-neptune-sg"
  })
}

# SageMaker Notebook Instance
resource "aws_sagemaker_notebook_instance" "neptune" {
  name                    = "sd-graph-db-poc-notebook"
  role_arn                = aws_iam_role.sagemaker_role.arn
  instance_type           = "ml.t3.medium"
  subnet_id               = var.private_subnet_ids[0]
  security_groups         = [aws_security_group.sagemaker_sg.id]
  platform_identifier     = "notebook-al2-v2"
  root_access             = "Enabled"
  direct_internet_access  = "Enabled"

  tags = merge(var.common_tags, {
    sd_Name = "sd-graph-db-poc-sagemaker"
  })
}

# Security Group for SageMaker
resource "aws_security_group" "sagemaker_sg" {
  name        = "sd-graph-db-poc-sagemaker-sg"
  description = "Security group for SageMaker notebook"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    sd_Name = "sd-graph-db-poc-sagemaker-sg"
  })
}

# IAM Role for SageMaker
resource "aws_iam_role" "sagemaker_role" {
  name = "sd-graph-db-poc-sagemaker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# IAM Policy for SageMaker
# IAM Policy for SageMaker
resource "aws_iam_role_policy" "sagemaker_policy" {
  name = "sd-graph-db-poc-sagemaker-policy"
  role = aws_iam_role.sagemaker_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:${var.cloud_partition}:s3:::*",
          "arn:${var.cloud_partition}:s3:::*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "neptune-db:*",
          "neptune-db:Connect",
          "neptune-db:GetEngineStatus",
          "neptune-db:GetQueryStatus",
          "neptune-db:CancelQuery"
        ]
        Resource = [
          aws_neptune_cluster.graph_db.arn,
          "${aws_neptune_cluster.graph_db.arn}/*",
          "arn:aws:rds:us-east-1:067303779378:cluster:db-neptune-1",
          "arn:aws:rds:us-east-1:067303779378:cluster:db-neptune-1/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:*"
        ]
        Resource = "*"
      }
    ]
  })
}


# Add AmazonSageMakerFullAccess policy
resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = "arn:${var.cloud_partition}:iam::aws:policy/AmazonSageMakerFullAccess"
}

# Add CloudWatch Logs permissions
resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Add VPC permissions for SageMaker
resource "aws_iam_role_policy" "vpc_access" {
  name = "vpc-access"
  role = aws_iam_role.sagemaker_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DeleteNetworkInterface",
          "ec2:DeleteNetworkInterfacePermission",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcs",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

# VPC Endpoints for SageMaker
resource "aws_vpc_endpoint" "sagemaker_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.sagemaker.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.sagemaker_sg.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    sd_Name = "sd-sagemaker-api-vpc-endpoint"
  })
}

resource "aws_vpc_endpoint" "sagemaker_runtime" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.sagemaker.runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.sagemaker_sg.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    sd_Name = "sd-sagemaker-runtime-vpc-endpoint"
  })
}

# Neptune VPC Endpoints
# resource "aws_vpc_endpoint" "neptune" {
#   vpc_id              = var.vpc_id
#   service_name        = "com.amazonaws.${var.aws_region}.neptune-db"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = var.private_subnet_ids
#   security_group_ids  = [aws_security_group.neptune_sg.id]
#   private_dns_enabled = true

#   tags = merge(var.common_tags, {
#     sd_Name = "sd-neptune-vpc-endpoint"
#   })
# }
