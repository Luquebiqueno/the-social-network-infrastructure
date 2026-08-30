locals {
  resource_prefix = "${var.name_prefix}-${var.environment}"

  public_subnets = {
    for index, cidr in var.public_subnet_cidrs : index => {
      cidr              = cidr
      availability_zone = var.availability_zones[index]
    }
  }

  private_subnets = {
    for index, cidr in var.private_subnet_cidrs : index => {
      cidr              = cidr
      availability_zone = var.availability_zones[index]
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${local.resource_prefix}-vpc" })

  lifecycle {
    precondition {
      condition = (
        length(var.availability_zones) > 0 &&
        length(var.public_subnet_cidrs) == length(var.availability_zones) &&
        length(var.private_subnet_cidrs) == length(var.availability_zones)
      )
      error_message = "availability_zones, public_subnet_cidrs, and private_subnet_cidrs must have the same non-zero length."
    }
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${local.resource_prefix}-igw" })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${local.resource_prefix}-public-${each.key + 1}"
      Tier = "public"
    }
  )
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name = "${local.resource_prefix}-private-${each.key + 1}"
      Tier = "private"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, { Name = "${local.resource_prefix}-public-rt" })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${local.resource_prefix}-private-rt" })
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
