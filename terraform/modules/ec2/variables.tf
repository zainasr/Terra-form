variable "project_name" {
  type        = string
  description = "Project name for tagging"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "subnet_id" {
  type        = string
  description = "Subnet where EC2 will be launched"
}

variable "instance_profile_name" {
  type        = string
  description = "IAM instance profile name"
}

variable "ssh_ingress_cidr_blocks" {
  type        = list(string)
  description = "List of IPv4 CIDR blocks allowed to access the instance via SSH (port 22)"
  default     = ["0.0.0.0/0"]
}

variable "egress_cidr_blocks" {
  type        = list(string)
  description = "List of IPv4 CIDR blocks allowed for outbound traffic"
  default     = ["0.0.0.0/0"]
}

variable  "alb_security-grp-id" {
  type      = string
  description = "Source security grp for ingress 80 port"

}
