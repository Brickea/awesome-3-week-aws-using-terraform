// s3 access policy for ec2 instance
// webapp.dev/prod.zixiao.wang
resource "aws_iam_policy" "s3_access_role_policy" {
  name        = "WebAppS3"

  policy = file("policy/s3_access_policy.json")
  depends_on = [aws_iam_role.s3_access_role]
}

resource "aws_iam_role_policy_attachment" "s3_access_role_policy-attach" {
  role       = aws_iam_role.s3_access_role.name // attach to role EC2-CSYE6225 
  policy_arn = aws_iam_policy.s3_access_role_policy.arn // Policy WebAppS3

  depends_on = [aws_iam_role.s3_access_role]
}

// CodeDeploy-EC2-S3 Policy for the Server (EC2)
// Get List codedeploy.awesome.me
resource "aws_iam_policy" "s3_codeDeply_role_policy" {
  name        = "CodeDeploy-EC2-S3"

  policy = file("policy/codedeploy_role.json")
  depends_on = [aws_iam_role.s3_access_role]
}

resource "aws_iam_role_policy_attachment" "s3_codeDeply_role_policy-attach" {
  role       = aws_iam_role.s3_access_role.name // attach to role EC2-CSYE6225 
  policy_arn = aws_iam_policy.s3_codeDeply_role_policy.arn // Policy CodeDeploy-EC2-S3

  depends_on = [aws_iam_role.s3_access_role]
}

// AWSCodeDeployPolicy
resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codeDeployService_access_role.name
}

//*********************************************************************************

// s3 access roles for ec2 instance
resource "aws_iam_role" "s3_access_role" {
  name = "awesome-ec2"

  assume_role_policy = file("policy/s3_assume_policy.json")
}

// codedeploy service role
resource "aws_iam_role" "codeDeployService_access_role" {
  name = "CodeDeployServiceRole"

  assume_role_policy = file("policy/codedeploy_assume.policy.json")
}

//*********************************************************************************\

// User profile for ec2 instance
resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3-access"
  role = aws_iam_role.s3_access_role.name
}
