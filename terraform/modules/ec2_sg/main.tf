

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Security group for EC2 with SSH and ALB access"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-sg"
  }
}

# 1. Egress: Allow all outbound
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = var.egress_cidr_blocks[0]
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "from_alb" {
  security_group_id        = aws_security_group.ec2.id
  referenced_security_group_id = var.alb_security-grp-id
  from_port                = var.app_port
  to_port                  = var.app_port
  ip_protocol                 = "tcp"
}



/*
resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-${var.environment}-deployer" 
  public_key = file("~/.ssh/terraform-demo.pub")
}
*/

