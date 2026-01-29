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



resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Minimal security group for EC2"
  vpc_id      = data.aws_subnet.selected.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-sg"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = "${var.egress_cidr_blocks}"
    ipv6_cidr_blocks = ["::/0"]
  }
}

/*
resource "aws_vpc_security_group_ingress_rule" "ssh_ipv4" {
  for_each = toset(var.ssh_ingress_cidr_blocks)

  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = each.value
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "SSH from allowed IPv4 CIDR"
}
*/


resource "aws_vpc_security_group_ingress_rule" "http_from_alb" {
  security_group_id = aws_security_group.ec2.id
  referenced_security_group_id = "${var.alb_security-grp-id}"
  from_port       = 80
  to_port         = 80
  ip_protocol        = "tcp"
  description     = "Allow HTTP from ALB"
}





resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-${var.environment}-deployer" 
  public_key = file("~/.ssh/terraform-demo.pub")
}



resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  iam_instance_profile        = var.instance_profile_name
  key_name = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  user_data = local.user_data

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2"
    Environment = var.environment
  }
}

