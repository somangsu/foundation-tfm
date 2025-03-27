locals {
  vpc_tags = merge(var.common_tags, {
    sd_Name = "sd-main-vpc"
  })

  igw_tags = merge(var.common_tags, {
    sd_Name = "sd-main-igw"
  })

  public_subnet_tags = {
    for i in range(4) :
    i => merge(var.common_tags, {
      sd_Name = "sd-public-subnet-${i + 1}"
      sd_Tier = "Public"
      sd_AZ   = data.aws_availability_zones.available.names[i]
    })
  }

  private_subnet_tags = {
    for i in range(4) :
    i => merge(var.common_tags, {
      sd_Name = "sd-private-subnet-${i + 1}"
      sd_Tier = "Private"
      sd_AZ   = data.aws_availability_zones.available.names[i]
    })
  }

  nat_eip_tags = merge(var.common_tags, {
    sd_Name = "sd-nat-eip"
  })

  nat_gateway_tags = merge(var.common_tags, {
    sd_Name = "sd-nat-gateway"
  })

  public_rt_tags = merge(var.common_tags, {
    sd_Name = "sd-public-rt"
    sd_Tier = "Public"
  })

  private_rt_tags = merge(var.common_tags, {
    sd_Name = "sd-private-rt"
    sd_Tier = "Private"
  })
}
