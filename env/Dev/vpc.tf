# Locals
locals {
  az_1                   = "us-east-1a"
  az_2                   = "us-east-1b"
  private_IP1            = "10.0.6.6"
  private_IP2            = "10.0.7.7"
  ssh_ingress_from_port  = 22
  ssh_ingress_to_port    = 22
  http_ingress_from_port = 80
  http_ingress_to_port   = 80
}

#  VPC Configuration
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.env}_vpc"
  }
}


# Subnet Configuration

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.priv1_cidr
  availability_zone = local.az_1

  tags = {
    Name = "private_subnet_1"
  }
}


resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.priv2_cidr
  availability_zone = local.az_2

  tags = {
    Name = "private_subnet_2"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pub1_cidr
  availability_zone = local.az_1

  tags = {
    Name = "public_subnet_1"
  }
}


resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.pub2_cidr
  availability_zone = local.az_2

  tags = {
    Name = "public_subnet_2"
  }
}

# Internet Gateway setup
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

# resource "aws_instance" "foo" {
# ... other arguments ...

#   depends_on = [aws_internet_gateway.gw]
# }

# Public Route Table

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.env}_rt"
  }
}

# Route Table Association

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.rt.id
}

# Network Interface/Elastic IP

resource "aws_network_interface" "multi-ip" {
  subnet_id   = aws_subnet.public_subnet_1.id
  private_ips = [local.private_IP1, local.private_IP2]
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.multi-ip.id
  associate_with_private_ip = local.private_IP1
}

resource "aws_eip" "two" {
  vpc                       = true
  network_interface         = aws_network_interface.multi-ip.id
  associate_with_private_ip = local.private_IP2
}

# Nat Gateway
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.one.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "${var.env}_nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.two.id
  subnet_id     = aws_subnet.public_subnet_2.id

  tags = {
    Name = "${var.env}_nat"
  }

  depends_on = [aws_internet_gateway.gw]
}

# Security Group

resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Allow certain traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "ssh"
    from_port   = local.ssh_ingress_from_port
    to_port     = local.ssh_ingress_to_port
    protocol    = "tcp"
    cidr_blocks = [var.priv1_cidr, var.priv2_cidr]

  }

  ingress {
    description = "http"
    from_port   = local.http_ingress_from_port
    to_port     = local.http_ingress_to_port
    protocol    = "tcp"
    cidr_blocks = [var.pub1_cidr, var.pub2_cidr]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env}_sg"
  }
}


