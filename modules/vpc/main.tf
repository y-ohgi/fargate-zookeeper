# VPC
resource "aws_vpc" "this" {
  cidr_block = "${var.vpc_cidr}"

  tags = {
    Name = "${var.name}"
  }

  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Public Subnet
resource "aws_subnet" "publics" {
  count = "${length(var.public_subnet_cidrs)}"

  vpc_id = "${aws_vpc.this.id}"

  availability_zone = "${var.azs[count.index]}"
  cidr_block        = "${var.public_subnet_cidrs[count.index]}"

  tags = {
    Name = "${var.name}-public-${count.index}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_eip" "nat" {
  count = "${length(var.public_subnet_cidrs)}"

  vpc = true

  tags = {
    Name = "${var.name}-natgw-${count.index}"
  }
}

resource "aws_nat_gateway" "this" {
  count = "${length(var.public_subnet_cidrs)}"

  subnet_id     = "${element(aws_subnet.publics.*.id, count.index)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"

  tags = {
    Name = "${var.name}-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.this.id}"

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = "${aws_route_table.public.id}"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnet_cidrs)}"

  subnet_id      = "${element(aws_subnet.publics.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

# Private Subnet
resource "aws_subnet" "privates" {
  count = "${length(var.private_subnet_cidrs)}"

  vpc_id = "${aws_vpc.this.id}"

  availability_zone = "${var.azs[count.index]}"
  cidr_block        = "${var.private_subnet_cidrs[count.index]}"

  tags = {
    Name = "${var.name}-private-${count.index}"
  }
}

resource "aws_route_table" "privates" {
  count = "${length(var.private_subnet_cidrs)}"

  vpc_id = "${aws_vpc.this.id}"

  tags = {
    Name = "${var.name}-private-${count.index}"
  }
}

resource "aws_route" "privates" {
  count = "${length(var.private_subnet_cidrs)}"

  destination_cidr_block = "0.0.0.0/0"

  route_table_id = "${element(aws_route_table.privates.*.id, count.index)}"
  nat_gateway_id = "${element(aws_nat_gateway.this.*.id, count.index)}"
}

resource "aws_route_table_association" "privates" {
  count = "${length(var.private_subnet_cidrs)}"

  subnet_id      = "${element(aws_subnet.privates.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.privates.*.id, count.index)}"
}
