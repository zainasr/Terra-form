# Environment
output "environment" {
  value       = var.environment
  description = "Environment name"
}

# Network
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs (one per AZ)"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Private subnet IDs (one per AZ)"
}

# IAM
output "ec2_instance_profile" {
  value       = module.iam.ec2_instance_profile_name
  description = "IAM instance profile for EC2/ASG instances"
}

output "ec2_role_name" {
  value       = module.iam.ec2_role_name
  description = "IAM role name for EC2/ASG instances"
}

# ASG
output "asg_name" {
  value       = module.asg.asg_name
  description = "Auto Scaling Group name"
}

# ALB
output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "ALB DNS name (use for app URL)"
}

output "alb_logs_bucket" {
  value       = module.monitoring.alb_logs_bucket
  description = "S3 bucket for ALB access logs"
}

# ACM (for manual DNS validation)
output "dns_validations" {
  value       = module.acm.acm_dns_validation_records
  description = "Add these CNAME records to your DNS for HTTPS certificate validation"
}



