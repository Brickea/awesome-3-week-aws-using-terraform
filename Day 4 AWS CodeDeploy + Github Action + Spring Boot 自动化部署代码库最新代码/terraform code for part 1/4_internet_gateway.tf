resource "aws_internet_gateway" "my_first_ig" {
  vpc_id = aws_vpc.my_first_vpc.id

  tags = {
    Name = "my-first-internet-gateway"
  }
}