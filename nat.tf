resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = local.nat_eip_tags
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = local.nat_gateway_tags

  depends_on = [aws_internet_gateway.main]
}
