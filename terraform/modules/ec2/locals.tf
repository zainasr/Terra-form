locals {
  user_data = <<-EOF
    #!/bin/bash

##---------------##
## Logging helper
##---------------##
log() {
  echo "$(date +'%Y-%m-%dT%H:%M:%S%z') [user-data] $1"
}

log "User data script starting"

##---------------------------------------------##
## Update system and install necessary packages
##---------------------------------------------##
log "Updating system packages"
dnf update -y

##-------------------------------##
## Install or ensure SSM agent
##-------------------------------##
log "Installing AWS SSM Agent if absent"
if ! rpm -q amazon-ssm-agent; then
    dnf install -y amazon-ssm-agent
else
    log "SSM Agent already installed"
fi

log "Enabling and starting SSM Agent"
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

##--------------------------------##
## Install or ensure CloudWatch agent
##--------------------------------##
log "Installing CloudWatch Agent if absent"
if ! rpm -q amazon-cloudwatch-agent; then
    dnf install -y amazon-cloudwatch-agent
else
    log "CloudWatch Agent already installed"
fi

##--------------------------------##
## Install or ensure nginx
##--------------------------------##
log "Installing NGINX if absent"
if ! rpm -q nginx; then
    dnf install -y nginx
else
    log "NGINX already installed"
fi

log "Enabling and starting NGINX"
systemctl enable nginx
systemctl start nginx

##--------------------------------##
## Generate CloudWatch agent config
##--------------------------------##
CW_CONFIG_PATH="/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"
log "Creating CloudWatch agent configuration file at $CW_CONFIG_PATH"
cat > $CW_CONFIG_PATH << 'CWAGENT_JSON'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/app/terraform-platform/dev/nginx-access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/app/terraform-platform/dev/nginx-error",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}

CWAGENT_JSON

##-------------------------------##
## Start CloudWatch Agent with config
##-------------------------------##
log "Starting CloudWatch Agent with the new config"
amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:$CW_CONFIG_PATH -s

log "User data script complete"
EOF
}
