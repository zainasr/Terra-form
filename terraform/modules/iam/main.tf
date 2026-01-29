data "aws_iam_policy_document" "ec2_logs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}



resource "aws_iam_policy" "ec2_logs" {
  name        = "${var.project_name}-${var.environment}-ec2-logs"
  description = "Allow EC2 instances to write CloudWatch logs"

  policy = data.aws_iam_policy_document.ec2_logs.json
}


data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}



resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}


resource "aws_iam_role_policy_attachment" "ec2_logs" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2_logs.arn
}



resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name
}


data "aws_iam_policy_document" "ssm_core" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]
  }
}


resource "aws_iam_policy" "ssm_core" {
  name        = "${var.project_name}-${var.environment}-ec2-ssm"
  description = "Allow EC2 to communicate with SSM"

  policy = data.aws_iam_policy_document.ssm_core.json
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ssm_core.arn
}
