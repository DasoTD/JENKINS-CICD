variable "vpc_cidr" {}
variable "vpc_name" {}
variable "cidr_public_subnet" {}
variable "availability_zone" {}
variable "cidr_private_subnet" {}

output "capstoneJenkins_vpc_id" {
  value = aws_vpc.capstoneJenkins.id
}

output "capstoneJenkins_public_subnets" {
  value = aws_subnet.capstoneJenkins_public_subnets.*.id
}

output "public_subnet_cidr_block" {
  value = aws_subnet.capstoneJenkins_public_subnets.*.cidr_block
}

# Setup VPC
resource "aws_vpc" "capstoneJenkins" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}


# Setup public subnet
resource "aws_subnet" "capstoneJenkins_public_subnets" {
  count             = length(var.cidr_public_subnet)
  vpc_id            = aws_vpc.capstoneJenkins.id
  cidr_block        = element(var.cidr_public_subnet, count.index)
  availability_zone = element(var.availability_zone, count.index)

  tags = {
    Name = "capstoneJenkins-public-subnet-${count.index + 1}"
  }
}

# Setup private subnet
resource "aws_subnet" "capstoneJenkins_private_subnets" {
  count             = length(var.cidr_private_subnet)
  vpc_id            = aws_vpc.capstoneJenkins.id
  cidr_block        = element(var.cidr_private_subnet, count.index)
  availability_zone = element(var.availability_zone, count.index)

  tags = {
    Name = "capstoneJenkins-private-subnet-${count.index + 1}"
  }
}

# Setup Internet Gateway
resource "aws_internet_gateway" "capstoneJenkins_public_internet_gateway" {
  vpc_id = aws_vpc.capstoneJenkins.id
  tags = {
    Name = "capstoneJenkins-1-igw"
  }
}

# Public Route Table
resource "aws_route_table" "capstoneJenkins_public_route_table" {
  vpc_id = aws_vpc.capstoneJenkins.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.capstoneJenkins_public_internet_gateway.id
  }
  tags = {
    Name = "capstoneJenkins_public-rt"
  }
}

# Public Route Table and Public Subnet Association
resource "aws_route_table_association" "capstoneJenkins_public_rt_subnet_association" {
  count          = length(aws_subnet.capstoneJenkins_public_subnets)
  subnet_id      = aws_subnet.capstoneJenkins_public_subnets[count.index].id
  route_table_id = aws_route_table.capstoneJenkins_public_route_table.id
}

# Private Route Table
resource "aws_route_table" "capstoneJenkins_private_subnets" {
  vpc_id = aws_vpc.capstoneJenkins.id
  #depends_on = [aws_nat_gateway.nat_gateway]
  tags = {
    Name = "capstoneJenkins-1-private-rt"
  }
}

# Private Route Table and private Subnet Association
resource "aws_route_table_association" "capstoneJenkins_private_rt_subnet_association" {
  count          = length(aws_subnet.capstoneJenkins_private_subnets)
  subnet_id      = aws_subnet.capstoneJenkins_private_subnets[count.index].id
  route_table_id = aws_route_table.capstoneJenkins_private_subnets.id
}