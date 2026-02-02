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