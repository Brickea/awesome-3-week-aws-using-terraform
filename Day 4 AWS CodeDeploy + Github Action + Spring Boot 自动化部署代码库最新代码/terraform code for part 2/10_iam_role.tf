// GH-Upload-To-S3 Policy for GitHub Actions to Upload to AWS S3
// Get Put List avs.codedeploy.dev/prod.brickea.me
resource "aws_iam_policy" "s3_ghUpLoad_role_policy" {
  name        = "GH_Upload_To_S3_policy"
  policy = file("policy/cicd_upload_s3_file.json")
}

resource "aws_iam_user_policy_attachment" "s3_ghUpLoad_user_policy_attach" {
  user       = "cicd"
  policy_arn = aws_iam_policy.s3_ghUpLoad_role_policy.arn
}

// GH-Code-Deploy Policy for GitHub Actions to Call CodeDeploy
resource "aws_iam_policy" "cicd_deploy_call_codeDeply_policy" {
  name        = "cicd_call_codedeploy_policy"
  
  policy = file("policy/cicd_call_codedeploy.json")
}

resource "aws_iam_user_policy_attachment" "gh_code_deploy_call_codeDeply_user_policy_attach" {
  user       = "cicd"
  policy_arn = aws_iam_policy.cicd_deploy_call_codeDeply_policy.arn
}

// Give access to github for operating the ec2
resource "aws_iam_policy" "cicd_ec2_role_policy" {
  name        = "cicd_ec2_role_policy"
  policy = file("policy/cicd_ec2.json")
}

resource "aws_iam_user_policy_attachment" "cicd_ec2_policy_attach" {
  user       = "cicd"
  policy_arn = aws_iam_policy.cicd_ec2_role_policy.arn
}

// CodeDeploy-EC2-S3 Policy for the Server (EC2)
// Get List codedeploy.awesome.me
resource "aws_iam_policy" "s3_codeDeply_role_policy" {
  name        = "EC2_access_S3_codedeploy_policy"

  policy = file("policy/ec2_codedeploy_s3.json")
}

resource "aws_iam_role_policy_attachment" "s3_codeDeply_role_policy_attach" {
  role       = aws_iam_role.ec2_codedeploy_s3_access_role.name // attach to role EC2-AVS
  policy_arn = aws_iam_policy.s3_codeDeply_role_policy.arn // Policy CodeDeploy-EC2-S3

}

// AWSCodeDeployPolicy attach to role for creating codedeploy application
resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.codeDeployService_access_role.name
}

//*********************************************************************************

// codedeploy s3 access roles for ec2 instance
resource "aws_iam_role" "ec2_codedeploy_s3_access_role" {
  name = "ec2_codedeploy_s3_access_role"

  assume_role_policy = file("policy/ec2_codedeploy_s3_role_assume.json")
}

// codedeploy service role for creating codedeploy application
resource "aws_iam_role" "codeDeployService_access_role" {
  name = "CodeDeployServiceRole"

  assume_role_policy = file("policy/codedeploy_application_role_assume.json")
}

//*********************************************************************************\
// User profile for ec2 instance
resource "aws_iam_instance_profile" "ec2_codedeploy_s3_access_profile" {
  name = "ec2_codedeploy_s3_access_profile"
  role = aws_iam_role.ec2_codedeploy_s3_access_role.name
}

