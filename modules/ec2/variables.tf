variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the EC2 instance will be created"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the EC2 instance will be created"
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instance"
  default     = "t3.micro"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "cloud_partition" {
  type        = string
  description = "cloud partition for the region"
}