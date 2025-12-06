provider "aws" {
  region = var.region
}

# 1. Get Availability Zones automatically
data "aws_availability_zones" "available" {
  state = "available"
}

# 2. Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "My-3-Tier-VPC"
  }
}

# ==========================================
# Tier 1: Public Subnets & Internet Gateway
# ==========================================

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "IGW" }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # This makes them "Public"

  tags = {
    Name = "public${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ==========================================
# Tier 2: Private Subnets & NAT Gateway
# ==========================================

# Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

# NAT Gateway (Must live in a Public Subnet to work)
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Place it in the first public subnet

  tags = { Name = "NGW_GUI" }
  
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private${count.index + 1}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# ==========================================
# Tier 3: Internal/Database Subnets
# ==========================================

resource "aws_subnet" "internal" {
  count             = length(var.internal_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.internal_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "internal${count.index + 1}"
  }
}

# Internal Route Table (Local Route only - No Internet)
resource "aws_route_table" "internal" {
  vpc_id = aws_vpc.main.id
  # We do NOT add a 0.0.0.0/0 route here. 
  # This isolates the DBs completely from the internet.

  tags = { Name = "internal-rt" }
}

resource "aws_route_table_association" "internal" {
  count          = length(var.internal_subnets)
  subnet_id      = aws_subnet.internal[count.index].id
  route_table_id = aws_route_table.internal.id
}
