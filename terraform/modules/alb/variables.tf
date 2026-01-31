variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
}

variable "vpc_id" {
  description = "VPC where the ALB will live"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "target_instance_id" {
  description = "EC2 instance ID to register with the ALB"
  type        = string
}

variable "target_port" {
  description = "Port on the EC2 instance to send traffic to"
  type        = number
  default     = 80 
}

variable "egress_cidr_blocks" {
  type        = list(string)
  description = "List of IPv4 CIDR blocks allowed for outbound traffic"
  default     = ["0.0.0.0/0"]
}

variable "log_bucket" {
  type  = string
  description = "name of bucket to where alb add logs"
  
}


variable "site_cert" { 
  description = "certificate"
}