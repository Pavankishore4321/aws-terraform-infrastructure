# ─────────────────────────────────────────────────────────────────────────────
# Module: VPC
# Project: AspTax (Incresol Software Services)
# Creates: VPC, Public/Private Subnets, IGW, NAT Gateway, Route Tables
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project}-${var.env}-vpc"
    Environment = var.env
    Project     = var.project
  }
}

# ── PUBLIC SUBNETS (for ALB, NAT Gateway) ────────────────────────────────────
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-${var.env}-public-subnet-${count.index + 1}"
    Environment = var.env
    Type        = "public"
  }
}

# ── PRIVATE SUBNETS (for EC2 app servers, RDS) ───────────────────────────────
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.project}-${var.env}-private-subnet-${count.index + 1}"
    Environment = var.env
    Type        = "private"
  }
}

# ── INTERNET GATEWAY ──────────────────────────────────────────────────────────
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project}-${var.env}-igw"
    Environment = var.env
  }
}

# ── ELASTIC IP FOR NAT GATEWAY ────────────────────────────────────────────────
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.project}-${var.env}-nat-eip" }
}

# ── NAT GATEWAY (allows private subnet EC2 to reach internet) ────────────────
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name        = "${var.project}-${var.env}-nat-gw"
    Environment = var.env
  }
}

# ── PUBLIC ROUTE TABLE ────────────────────────────────────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "${var.project}-${var.env}-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ── PRIVATE ROUTE TABLE ───────────────────────────────────────────────────────
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = { Name = "${var.project}-${var.env}-private-rt" }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
