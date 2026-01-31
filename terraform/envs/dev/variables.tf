variable "project_name" {
  description = "Project identifier"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}


variable "alert_email" {
  description = "alert email"
  type = string
}

variable "domain_name" {
  type = string
  description = "domain name"
}