resource "aws_iam_role" "cognito_auth_redirect" {
  count = var.users_management_type == "cognito" ? 1 : 0
  name = "${local.name}-cognito-auth-redirect"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cognito_auth_redirect" {
  count = var.users_management_type == "cognito" ? 1 : 0
  policy = <<POLICY
{
"Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cognito_auth_redirect" {
  policy_arn = aws_iam_policy.cognito_auth_redirect[0].arn
  role       = aws_iam_role.cognito_auth_redirect[0].name
}


module "cognito_auth_redirect" {
  count = var.users_management_type == "cognito" ? 1 : 0
  source          = "terraform-aws-modules/lambda/aws"
  version         = "2.7.0"
  create_package  = true
  create_role     = false
  create          = true
  create_layer    = false
  create_function = true
  publish         = true
  function_name   = "${local.name}-cognito-auth-redirect"
  runtime         = "python3.9"
  handler         = "app.handler"
  memory_size     = 512
  timeout         = 30
  lambda_role     = aws_iam_role.cognito_auth_redirect[0].arn
  package_type    = "Zip"
  source_path     = "${path.module}/lambdas/cognito-auth-redirect"
}
