
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

