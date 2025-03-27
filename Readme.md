
#for us-gov cloud modify variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-gov-west-1"
}

variable "cloud_partition" {
  description = "Cloud partition to use"
  type        = string
  default     = "aws-us-gov"
}



<!-- one time only run this -->
cd backend
terraform init
terraform plan
terraform apply

<!-- IAC -->
<!-- 
After the backend is created, return to the main VPC configuration directory and initialize with the new backend: 
-->
cd ..
terraform init
terraform plan
terraform apply


Outputs:

availability_zones = tolist([
  "us-east-1a",
  "us-east-1b",
  "us-east-1c",
  "us-east-1d",
  "us-east-1e",
  "us-east-1f",
])
ec2_instance_id = "i-0a648f53f3efaf8a1"
ec2_private_ip = "10.0.19.111"
nat_gateway_ip = "34.194.196.137"
neptune_endpoint = "sd-graph-db-poc.cluster-cp0un9ivynav.us-east-1.neptune.amazonaws.com"
private_subnet_ids = [
  "subnet-05b85df4b6d4f18e9",
  "subnet-09cd8aafca38fd0c7",
  "subnet-06f9cfc48e84fef13",
  "subnet-0c76b0dc3b8a320e9",
]
public_subnet_ids = [
  "subnet-066f31a9d6e291e8e",
  "subnet-05cf35b687bb53a82",
  "subnet-06a18b55515e96588",
  "subnet-08d0005255b3419e5",
]
s3_bucket_name = "sd-graph-db-poc-067303779378"
sagemaker_notebook_url = "sd-graph-db-poc-notebook.notebook.us-east-1.sagemaker.aws"
vpc_cidr_block = "10.0.0.0/18"
vpc_id = "vpc-020cfc7597ce08e1b"