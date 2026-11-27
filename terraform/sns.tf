# SNS topic
resource "aws_sns_topic" "daily_report" {
  name = "${var.project_name}-sns-daily-report-topic"
}

resource "aws_sns_topic_subscription" "email_daily_report" {
  topic_arn = aws_sns_topic.daily_report.arn
  protocol  = "email"
  endpoint  = var.daily_report_email
}