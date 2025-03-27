module "s3_graph_db_poc" {
  source                 = "./modules/s3"
  common_tags           = var.common_tags
  vpc_id                = aws_vpc.main.id
  private_route_table_ids = [aws_route_table.private.id]
  aws_region            = var.aws_region
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "ec2_graph_db_poc" {
  source        = "./modules/ec2"
  common_tags   = var.common_tags
  vpc_id        = aws_vpc.main.id
  subnet_id     = aws_subnet.private[0].id
  s3_bucket_arn = module.s3_graph_db_poc.bucket_arn
  kms_key_arn   = module.s3_graph_db_poc.kms_key_arn
  ami_id        = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  aws_region    = var.aws_region
  cloud_partition = var.cloud_partition
}

module "cloudwatch" {
  source          = "./modules/cloudwatch"
  common_tags     = var.common_tags
  vpc_id          = aws_vpc.main.id
  ec2_instance_id = module.ec2_graph_db_poc.instance_id
  s3_bucket_name  = module.s3_graph_db_poc.bucket_name
}

# module "neptune" {
#   source                  = "./modules/neptune"
#   common_tags            = var.common_tags
#   vpc_id                 = aws_vpc.main.id
#   private_subnet_ids     = aws_subnet.private[*].id
#   aws_region             = var.aws_region
#   private_route_table_ids = [aws_route_table.private.id]
#   # cloud_partition = var.cloud_partition
# }


