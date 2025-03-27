variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    sd_Environment = "Production"
    sd_Project     = "Infrastructure"
    sd_Owner       = "DevOps"
    sd_ManagedBy   = "Terraform"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/18"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cloud_partition" {
  description = "Cloud partition to use"
  type        = string
  default     = "aws"
}

variable "private_route_table_ids" {
  type        = list(string)
  description = "List of private route table IDs"
  default     = []  # Optional: provide a default empty list
}

