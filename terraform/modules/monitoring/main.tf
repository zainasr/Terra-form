resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.project_name}-${var.environment}-alb-logs"
  force_destroy = true
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id
  # Policy requires Ownership Controls to be created first
  depends_on = [aws_s3_bucket_ownership_controls.alb_logs]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowALBLogDelivery"
        Effect = "Allow"
        Principal = {
          # Use the Service Principal for modern regions
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action = ["s3:PutObject"]
        # FIXED: Specific path ALB writes to: bucket/prefix/AWSLogs/account_id/*
        Resource = [
          "${aws_s3_bucket.alb_logs.arn}/alb-access-logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        ]
      }
    ]
  })
}










resource "aws_s3_bucket_server_side_encryption_configuration" "sse_bucket" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # This is SSE-S3
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_cloudwatch_log_group" "ec2_logs" {
  name              = "/app/${var.project_name}/${var.environment}/ec2"
  retention_in_days = 14
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}


resource "aws_cloudwatch_metric_alarm" "asg_insufficient_capacity" {
  alarm_name          = "${var.project_name}-${var.environment}-asg-insufficient-capacity"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = 60
  statistic           = "Average"
  threshold           = 1

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }



  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}


resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    LoadBalancer = "${var.alb_arn_suffix}"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}



resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}



