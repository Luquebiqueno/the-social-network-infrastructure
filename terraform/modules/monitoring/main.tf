locals {
  resource_prefix = "${var.name_prefix}-${var.environment}"
  log_groups      = toset(["backend", "frontend", "keycloak"])
}

resource "aws_sns_topic" "alerts" {
  name              = "${local.resource_prefix}-infrastructure-alerts"
  kms_master_key_id = "alias/aws/sns"

  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  count = var.notification_email == null ? 0 : 1

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_cloudwatch_log_group" "application" {
  for_each = local.log_groups

  name              = "/${var.name_prefix}/${var.environment}/${each.value}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${local.resource_prefix}-ec2-high-cpu"
  alarm_description   = "EC2 CPU utilization is above the configured threshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = var.cpu_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = var.ec2_instance_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  alarm_name          = "${local.resource_prefix}-ec2-status-check-failed"
  alarm_description   = "EC2 instance or system status check failed"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = var.ec2_instance_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = var.tags
}
