
# VPC Flow Logs
resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id

  tags = merge(var.common_tags, {
    sd_Name = "sd-vpc-flow-logs"
  })
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/sd/vpc/flow-logs"
  retention_in_days = 30

  tags = merge(var.common_tags, {
    sd_Name = "sd-vpc-flow-logs"
  })
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_logs_role" {
  name = "sd-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# IAM Policy for VPC Flow Logs
resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "sd-vpc-flow-logs-policy"
  role = aws_iam_role.flow_logs_role.id

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
        Resource = ["${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"]
      }
    ]
  })
}

# CloudWatch Log Group for SSM Session Manager
resource "aws_cloudwatch_log_group" "ssm_sessions" {
  name              = "/sd/ssm/sessions"
  retention_in_days = 30

  tags = merge(var.common_tags, {
    sd_Name = "sd-ssm-session-logs"
  })
}

# CloudWatch Log Group for API Gateway Access Logs
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/sd/apigateway/access-logs"
  retention_in_days = 30

  tags = merge(var.common_tags, {
    sd_Name = "sd-api-gateway-access-logs"
  })
}

# CloudWatch Metrics and Alarms
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "sd-graph-db-poc-ec2-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors EC2 CPU utilization"
  alarm_actions      = []  # Add SNS topic ARN if needed

  dimensions = {
    InstanceId = var.ec2_instance_id
  }

  tags = merge(var.common_tags, {
    sd_Name = "sd-ec2-cpu-alarm"
  })
}

# S3 Bucket Metrics Alarm
resource "aws_cloudwatch_metric_alarm" "s3_bucket_size" {
  alarm_name          = "sd-graph-db-poc-s3-bucket-size"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "BucketSizeBytes"
  namespace          = "AWS/S3"
  period             = "86400"
  statistic          = "Average"
  threshold          = "5368709120"  # 5GB in bytes
  alarm_description  = "This metric monitors S3 bucket size"
  alarm_actions      = []  # Add SNS topic ARN if needed

  dimensions = {
    BucketName = var.s3_bucket_name
    StorageType = "StandardStorage"
  }

  tags = merge(var.common_tags, {
    sd_Name = "sd-s3-size-alarm"
  })
}
