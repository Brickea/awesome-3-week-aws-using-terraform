resource "aws_subnet" "my_subnet_alpha" {
  vpc_id     = aws_vpc.my_first_vpc.id
  cidr_block = "10.0.0.0/17"

  tags = {
    Name = "Subnet alpha"
  }
}

resource "aws_subnet" "my_subnet_beta" {
  vpc_id     = aws_vpc.my_first_vpc.id
  cidr_block = "10.0.128.0/17"

  tags = {
    Name = "Subnet beta"
  }
}