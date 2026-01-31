data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

data "aws_subnet" "selected" {
  id = var.subnet_id
}

locals {
  user_data = base64encode(<<EOF
#!/bin/bash
# 1. Setup logging for the user-data execution itself
exec > /var/log/user-data.log 2>&1

log() {
  echo "$(date +'%Y-%m-%dT%H:%M:%S%z') [user-data] \$1"
}

log "User data script starting"

# 2. Install Packages
log "Updating and installing Nginx, SSM, and CloudWatch Agents"
dnf update -y
dnf install -y amazon-ssm-agent amazon-cloudwatch-agent nginx

# 3. Configure CloudWatch Agent
CW_CONFIG_DIR="/opt/aws/amazon-cloudwatch-agent/etc"
CW_CONFIG_PATH="$CW_CONFIG_DIR/amazon-cloudwatch-agent.json"

log "Creating CloudWatch agent configuration directory"
mkdir -p $CW_CONFIG_DIR

log "Writing CloudWatch configuration file"
cat > $CW_CONFIG_PATH << 'CWAGENT_JSON'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/app/terraform-platform/${var.environment}/nginx-access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/app/terraform-platform/${var.environment}/nginx-error",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
CWAGENT_JSON

# 4. Start Services
log "Starting Nginx and SSM"
systemctl enable --now nginx
systemctl enable --now amazon-ssm-agent

log "Starting CloudWatch Agent with the new config"
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:$CW_CONFIG_PATH -s

log "User data script execution finished successfully"
EOF
)
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Security group for EC2 with SSH and ALB access"
  vpc_id      = data.aws_subnet.selected.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-sg"
  }
}

# 1. Egress: Allow all outbound
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# 2. Ingress: SSH from World (For debugging)
resource "aws_vpc_security_group_ingress_rule" "ssh_all" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# 3. Ingress: HTTP from ALB only
# Note: Since ALB terminates 443 and talks to EC2 on 80, we open 80 here.
resource "aws_vpc_security_group_ingress_rule" "http_from_alb" {
  security_group_id            = aws_security_group.ec2.id
  referenced_security_group_id = var.alb_security-grp-id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-${var.environment}-deployer" 
  public_key = file("~/.ssh/terraform-demo.pub")
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  iam_instance_profile        = var.instance_profile_name
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  
  # Base64 encoding is the modern best practice for User Data
  user_data_base64            = local.user_data
  
  # This ensures that if you change the script, Terraform replaces the instance
  user_data_replace_on_change = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2"
    Environment = var.environment
  }
}