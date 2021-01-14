// 创建 用来进行代码部署的 S3---------------------------------------------
resource "aws_s3_bucket" "awesome_webapp_s3" {
  bucket = "codedeploy.awesome.me"
  acl    = "private"

  force_destroy = true // 无论此 s3 存储是否有内容存入，都允许 terraform 执行 destroy
  // 如果不写这个配置，会导致每一次 apply 之后必须手动清空 s3 之后才能正常执行 terraform destroy

  // 启用加密，对我们使用没有直接影响，只是让这个 s3 存储更安全
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  tags = {
    Name        = "awesome webapp codedeploy s3"
  }
}
