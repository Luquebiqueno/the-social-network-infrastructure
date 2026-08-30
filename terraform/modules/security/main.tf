locals {
  resource_prefix = "${var.name_prefix}-${var.environment}"
}

resource "aws_security_group" "ec2" {
  name        = "${local.resource_prefix}-ec2-sg"
  description = "Controls inbound web traffic and outbound access for the application EC2 instance"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${local.resource_prefix}-ec2-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = toset(var.allowed_http_cidrs)

  security_group_id = aws_security_group.ec2.id
  description       = "Public HTTP traffic"
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = toset(var.allowed_https_cidrs)

  security_group_id = aws_security_group.ec2.id
  description       = "Public HTTPS traffic"
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.ec2.id
  description       = "Required outbound access for updates and AWS services"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${local.resource_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "ecr_pull" {
  statement {
    sid       = "GetAuthorizationToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "PullApplicationImages"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = values(var.ecr_repository_arns)
  }
}

resource "aws_iam_role_policy" "ecr_pull" {
  count = length(var.ecr_repository_arns) > 0 ? 1 : 0

  name   = "${local.resource_prefix}-ecr-pull"
  role   = aws_iam_role.ec2.id
  policy = data.aws_iam_policy_document.ecr_pull.json
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.resource_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = var.tags
}
