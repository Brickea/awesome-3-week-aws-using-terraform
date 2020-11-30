resource "aws_security_group" "my_first_ec2_security_group" {
    
    name = "First ec2 security group"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }
}