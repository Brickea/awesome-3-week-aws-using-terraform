resource "aws_vpc" "my_first_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true

  tags = {
    Name = "my-first-vpc"
  }

}