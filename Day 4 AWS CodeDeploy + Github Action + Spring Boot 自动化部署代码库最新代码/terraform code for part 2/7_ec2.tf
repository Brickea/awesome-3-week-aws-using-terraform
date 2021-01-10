resource "aws_instance" "my_first_ec2_instance" {

    ami = "ami-077e9a928f0a740e3" 

    instance_type = "t2.micro" # 使用我们之前选的 instance type

    vpc_security_group_ids = [aws_security_group.my_first_ec2_security_group.id] # 使用我们创建的 安全组 注意这里 "aws_security_group." 后面接的名字是之前写的那个

    key_name = "awesome_terraform_aws" # 使用我们上一节中创建的 key pair

    subnet_id = aws_subnet.my_subnet_alpha.id

    iam_instance_profile = aws_iam_instance_profile.s3_access_profile.name

    associate_public_ip_address = true

    tags = {
        Name = "my-first-ec2-instance"
    }
}

resource "aws_instance" "my_second_ec2_instance" {

    ami = "ami-077e9a928f0a740e3"

    instance_type = "t2.micro" # 使用我们之前选的 instance type

    vpc_security_group_ids = [aws_security_group.my_first_ec2_security_group.id] # 使用我们创建的 安全组 注意这里 "aws_security_group." 后面接的名字是之前写的那个

    key_name = "awesome_terraform_aws" # 使用我们上一节中创建的 key pair

    subnet_id = aws_subnet.my_subnet_beta.id

    associate_public_ip_address = true

    tags = {
        Name = "my-second-ec2-instance"
    }
}