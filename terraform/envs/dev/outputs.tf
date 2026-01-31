output "environment" {
  value = var.environment
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "ec2_instance_profile" {
  value = module.iam.ec2_instance_profile_name
}

output "ec2_role_name" {
  value = module.iam.ec2_role_name
}

output "ec2_public_ip" {
  value = module.ec2.public_ip
}

output "alb_logs_bucket" {
  value = module.monitoring.alb_logs_bucket
}

output "dns_validations" {
  value  = module.acm.acm_dns_validation_records
}



