data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


resource "aws_launch_template" "this" {
  name_prefix = "${var.project_name}-${var.environment}-lt"

  iam_instance_profile {
    name = var.instance_profile_name
  }

  image_id      = data.aws_ami.linux.id
  instance_type = var.instance_type

  user_data = var.user_data

  network_interfaces {
    security_groups = [var.ec2_sg_id]
    associate_public_ip_address = false
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-${var.environment}-asg"
    }
  }
}

