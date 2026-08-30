output "sns_topic_arn" {
  description = "ARN of the SNS topic used by infrastructure alarms."
  value       = aws_sns_topic.alerts.arn
}

output "log_group_names" {
  description = "CloudWatch Log Group names keyed by application component."
  value       = { for name, group in aws_cloudwatch_log_group.application : name => group.name }
}

output "alarm_arns" {
  description = "ARNs of the EC2 CloudWatch alarms."
  value = {
    high_cpu            = aws_cloudwatch_metric_alarm.high_cpu.arn
    status_check_failed = aws_cloudwatch_metric_alarm.status_check_failed.arn
  }
}
