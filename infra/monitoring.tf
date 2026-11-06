resource "aws_sns_topic" "alerts" {
  name = "internship-alerts-topic"
  tags = merge(var.common_tags, {
    Name = "internship-alerts-topic"
  })
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "internship-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarm when CPU exceeds 70% for 5 minutes"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  
  dimensions = {
    InstanceId = aws_instance.web.id
  }

  tags = merge(var.common_tags, {
    Name = "internship-cpu-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  alarm_name          = "internship-status-check-failed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Maximum"
  threshold           = 1
  alarm_description   = "Alarm when status check fails"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  
  dimensions = {
    InstanceId = aws_instance.web.id
  }

  tags = merge(var.common_tags, {
    Name = "internship-status-check-alarm"
  })
}

resource "aws_budgets_budget" "monthly" {
  name              = "internship-monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.budget_amount
  limit_unit        = "USD"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}
