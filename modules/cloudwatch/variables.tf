variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for flow logs"
}

variable "ec2_instance_id" {
  type        = string
  description = "EC2 instance ID for CloudWatch alarms"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name for CloudWatch alarms"
}



