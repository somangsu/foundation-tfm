variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the endpoint will be created"
}

variable "private_route_table_ids" {
  type        = list(string)
  description = "List of private route table IDs"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}
