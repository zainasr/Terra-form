variable "project_name" {
  description = "Project name for IAM resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "asg_name" {
  description = "ASG name for ASG-level insufficient capacity alarm"
  type        = string
}

variable "alert_email" {
  description = "Email to send CloudWatch alerts"
  type        = string
}

variable "alb_arn_suffix"{
  description = "alb arn suffix"
  type = string
}