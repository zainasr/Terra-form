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


module "ec2" {
  source                  = "../../modules/ec2"
  project_name            = var.project_name
  environment             = var.environment
  subnet_id               = module.vpc.public_subnet_ids[0]
  instance_profile_name   = module.iam.ec2_instance_profile_name
  alb_security-grp-id     = module.alb.alb_sg_id
}

module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  target_instance_id = module.ec2.instance_id
  log_bucket         = module.monitoring.alb_logs_bucket
  
}

module monitoring {
  source = "../../modules/monitoring"
  project_name      = var.project_name
  environment       = var.environment
  instance_id       = module.ec2.instance_id
  alert_email       = var.alert_email
  alb_arn_suffix    = module.alb.alb_arn_suffix
}
