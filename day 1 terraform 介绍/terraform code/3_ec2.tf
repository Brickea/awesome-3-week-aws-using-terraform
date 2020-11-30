resource "aws_instance" "my_first_ec2_instance" {

    ami = "ami-0885b1f6bd170450c" # 使用之前我们选的 ubuntu 20 ami id

    instance_type = "t2.micro" # 使用我们之前选的 instance type

    vpc_security_group_ids = [aws_security_group.my_first_ec2_security_group.id] # 使用我们创建的 安全组 注意这里 "aws_security_group." 后面接的名字是之前写的那个

    key_name = "awesome_terraform_aws" # 使用我们上一节中创建的 key pair

    tags = {
        Name = "my-first-ec2-instance"
    }
}