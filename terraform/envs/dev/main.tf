module "vpc" {
  source       = "../../modules/vpc"
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = "10.0.0.0/16"
}



module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
  environment  = var.environment
}


module "ec2_sg" {
  source                  = "../../modules/ec2_sg"
  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  instance_profile_name   = module.iam.ec2_instance_profile_name
  alb_security-grp-id     = module.alb.alb_sg_id
}

module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  log_bucket         = module.monitoring.alb_logs_bucket
  site_cert          = module.acm.site_cert
  
}

module "monitoring" {
  source         = "../../modules/monitoring"
  project_name   = var.project_name
  environment    = var.environment
  asg_name       = module.asg.asg_name
  alert_email    = var.alert_email
  alb_arn_suffix = module.alb.alb_arn_suffix
}



module acm {
  source            = "../../modules/acm"
  project_name      = var.project_name
  environment       = var.environment
  domain_name       = var.domain_name
  alb_dns_name      = module.alb.alb_dns_name
  zone_id           = module.alb.zone_id
}

module "launch_template" {
  source = "../../modules/asg_launch_template"
  project_name = var.project_name
  environment  = var.environment
  instance_type = "t2.micro"
  instance_profile_name = module.iam.ec2_instance_profile_name
  ec2_sg_id = module.ec2_sg.ec2_sg_id
  user_data = local.user_data
}



module "asg" {
  source = "../../modules/asg"
  launch_template_id = module.launch_template.id
  private_subnet_ids = module.vpc.private_subnet_ids
  target_group_arn = module.alb.target_group_arn
  min_size = 2
  max_size = 4
  desired_capacity = 2
  project_name = var.project_name
  environment  = var.environment
}
