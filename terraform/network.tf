resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr
  tags       = local.standard_tags
}

# resource "aws_subnet" "example" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = var.subnet_example
#   availability_zone = "${data.aws_region.current.name}b"
#   tags              = local.standard_tags
# }


resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = local.standard_tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = local.standard_tags
}


resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id
  #allow ssh connections
  ingress {
    action     = "allow"
    protocol   = "tcp"
    rule_no    = 1
    from_port  = 22
    to_port    = 22
    cidr_block = "0.0.0.0/0"
  }
  #allow all outgoing traffic
  egress {
    action     = "allow"
    protocol   = "tcp"
    rule_no    = 2
    from_port  = 0
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
  }
}