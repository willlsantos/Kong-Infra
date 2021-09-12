/*==== The VPC ======*/
resource "aws_vpc" "VPC_KONG" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
  tags = {
    Name = "VPC KONG"
  }
}
/*==== Subnets ======*/
resource "aws_subnet" "Public_subnet_KONG" {
  vpc_id                  = aws_vpc.VPC_KONG.id
  cidr_block              = var.publicsCIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
  tags = {
    Name = "Public subnet Kong"
  }
}

/*==== Public ACL ======*/
resource "aws_network_acl" "Public_NACL_KONG" {
  vpc_id     = aws_vpc.VPC_KONG.id
  subnet_ids = [aws_subnet.Public_subnet_KONG.id]
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.publicdestCIDRblock
    from_port  = 22
    to_port    = 22
  }


  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.publicdestCIDRblock
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "Public NACL KONG"
  }
}
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "IGW_KONG" {
  vpc_id = aws_vpc.VPC_KONG.id
  tags = {
    Name = "Internet gateway KONG"
  }
}
/*==== Route table ======*/
resource "aws_route_table" "Public_RT_KONG" {
  vpc_id = aws_vpc.VPC_KONG.id
  tags = {
    Name = "Public Route table KONG"
  }
}
resource "aws_route" "internet_access_KONG" {
  route_table_id         = aws_route_table.Public_RT_KONG.id
  destination_cidr_block = var.publicdestCIDRblock
  gateway_id             = aws_internet_gateway.IGW_KONG.id
}
resource "aws_route_table_association" "Public_association" {
  subnet_id      = aws_subnet.Public_subnet_KONG.id
  route_table_id = aws_route_table.Public_RT_KONG.id
}
