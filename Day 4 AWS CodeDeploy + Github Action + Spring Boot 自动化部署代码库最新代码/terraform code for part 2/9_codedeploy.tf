// CodeDeploy Application
resource "aws_codedeploy_app" "awesome_codeDeploy_app" {
  compute_platform = "Server"
  name             = "awesome-codedeploy"
}

// CodeDeploy Application Group
resource "aws_codedeploy_deployment_group" "awesome_CD_group" {
  app_name              = aws_codedeploy_app.awesome_codeDeploy_app.name
  deployment_group_name = "awesome-deployment"
  service_role_arn      = aws_iam_role.codeDeployService_access_role.arn

  deployment_style {
    deployment_type   = "IN_PLACE"
  }

  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "my-first-ec2-instance"
    }
  }
}