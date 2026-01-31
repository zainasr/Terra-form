variable "domain_name" {
  description = "Root domain name (e.g., imdb-review.me)"
  type        = string
}

variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
}

variable "alb_dns_name" {
  type = string
  description = "alb dns name"
}

variable "zone_id"{
  type = string
  description = "alb zone_id"
}