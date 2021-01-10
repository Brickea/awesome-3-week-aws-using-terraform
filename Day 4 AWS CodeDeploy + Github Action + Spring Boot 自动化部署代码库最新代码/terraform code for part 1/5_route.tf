resource "aws_route_table" "my_first_route" {
  vpc_id = aws_vpc.my_first_vpc.id

  route {
    cidr_block = "0.0.0.0/0" // 让 alpha 拥有对外通讯能力
    gateway_id = aws_internet_gateway.my_first_ig.id
  }

  tags = {
    Name = "my-first-route"
  }
}

resource "aws_route_table" "my_second_route" {
  vpc_id = aws_vpc.my_first_vpc.id

  tags = {
    Name = "my-second-route"
  }
}

resource "aws_route_table_association" "alpha" {
  // 将子网和路由相关联
  subnet_id      = aws_subnet.my_subnet_alpha.id
  route_table_id = aws_route_table.my_first_route.id
}

resource "aws_route_table_association" "beta" {
  // 将子网和路由相关联
  subnet_id      = aws_subnet.my_subnet_beta.id
  route_table_id = aws_route_table.my_second_route.id
}