output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = data.aws_availability_zones.available.names
}

output "s3_bucket_name" {
  value = module.s3_graph_db_poc.bucket_name
}

output "ec2_instance_id" {
  value = module.ec2_graph_db_poc.instance_id
}

output "ec2_private_ip" {
  value = module.ec2_graph_db_poc.private_ip
}

output "neptune_endpoint" {
  value = module.neptune.neptune_endpoint
}

output "sagemaker_notebook_url" {
  value = module.neptune.sagemaker_notebook_url
}
