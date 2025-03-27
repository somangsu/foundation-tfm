variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where Neptune and SageMaker resources will be created"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "private_route_table_ids" {
  type        = list(string)
  description = "List of private route table IDs"
}


variable "cloud_partition" {
  description = "Cloud partition to use"
  type        = string
  default     = "aws"
}