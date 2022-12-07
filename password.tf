resource "random_password" "password" {
  length  = 32
  special = true
}

resource "aws_ssm_parameter" "password_ssm_parameter" {
  name  = "${var.prefix}-administrator-password"
  type  = "SecureString"
  value = random_password.password.result
}

resource "aws_iam_policy" "password_get_parameter_policy" {
  name   = "${var.prefix}-password-get-parameter-policy"
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "ssm:GetParameter",
        "Resource": "${aws_ssm_parameter.password_ssm_parameter.arn}"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "password_get_parameter_policy_attachment" {
  role       = aws_iam_role.windows_instance_role.name
  policy_arn = aws_iam_policy.password_get_parameter_policy.arn
}
