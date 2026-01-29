variable "project_name" {
  description = "Project name for IAM resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "instance_id" {
    description = "ec2 instance id for which aws_cloudwatch_metric_alarm created"
    type = string
}

variable "alert_email" {
  description = "Email to send CloudWatch alerts"
  type        = string
}

variable "alb_arn_suffix"{
  description = "alb arn suffix"
  type = string
}