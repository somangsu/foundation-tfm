terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "sd-tfm-state-bucket"
    key            = "vpc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sd-terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  # region = "us-gov-west-1"
  region = var.aws_region
  
  # Specify that this is a GovCloud provider
  # endpoints {
  #   s3 = "s3.${var.aws_region}.amazonaws.com"
  #   ec2 = "ec2.${var.aws_region}.amazonaws.com"
  #   kms = "kms.${var.aws_region}.amazonaws.com"
  #   iam = "iam.${var.cloud_partition}.amazonaws.com"
  #   neptune = "neptune.${var.aws_region}.amazonaws.com"
  #   sagemaker = "api.sagemaker.${var.aws_region}.amazonaws.com"
  # }
}


