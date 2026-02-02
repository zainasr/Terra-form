# Production-Grade AWS Infrastructure with Terraform

A comprehensive, production-ready infrastructure-as-code project demonstrating enterprise-level Terraform practices, modular architecture, and automated deployment workflows. This project showcases how to build, manage, and scale AWS infrastructure using industry best practices.

## 🎯 Project Overview

This project implements a complete, production-ready AWS infrastructure stack using Terraform, following HashiCorp's recommended practices and AWS Well-Architected Framework principles. The infrastructure includes networking, compute, load balancing, monitoring, and security components, all managed through Infrastructure as Code (IaC).

### Key Highlights

- ✅ **Modular Architecture**: Reusable, composable Terraform modules
- ✅ **Auto Scaling**: Production-ready ASG with launch templates and multi-AZ deployment
- ✅ **High Availability**: Private subnets across multiple AZs with NAT gateway
- ✅ **State Management**: Remote state with S3 backend and encryption
- ✅ **Security Best Practices**: IAM roles, security groups, least privilege access
- ✅ **HTTPS/TLS**: ACM certificate management with DNS validation
- ✅ **Observability**: CloudWatch logs, metrics, alarms, and SNS notifications
- ✅ **Production Patterns**: Security group rules, bucket policies, encryption at rest
- ✅ **CI/CD Ready**: Designed for automated deployment pipelines

---

## 🏗️ Architecture

```
                    Internet
                       │
            ┌──────────▼──────────┐
            │  Internet Gateway   │
            └──────────┬──────────┘
                       │
    ┌──────────────────┼──────────────────┐
    │  Public Subnets (Multi-AZ)          │
    │  ┌────────────┐    ┌────────────┐   │
    │  │ ALB        │    │ NAT GW     │   │
    │  │ HTTPS/HTTP │    │            │   │
    │  └─────┬──────┘    └─────┬──────┘   │
    └────────┼─────────────────┼──────────┘
             │                 │
    ┌────────▼─────────────────▼──────────┐
    │  Private Subnets (Multi-AZ)         │
    │  ┌─────────────────────────────┐    │
    │  │   Auto Scaling Group        │    │
    │  │  ┌────────┐    ┌────────┐   │    │
    │  │  │EC2-AZ1 │    │EC2-AZ2 │   │    │
    │  │  │(NGINX) │    │(NGINX) │   │    │
    │  │  └────────┘    └────────┘   │    │
    │  └─────────────────────────────┘    │
    └─────────────────────────────────────┘
```

### Infrastructure Components

1. **VPC Module** (`modules/vpc/`)
   - Custom VPC with DNS support
   - Public and private subnets (one per AZ for maximum availability)
   - Internet Gateway, NAT Gateway, route tables
   - Multi-AZ high availability design

2. **Auto Scaling Module** (`modules/asg/`, `modules/asg_launch_template/`)
   - Launch template with user data for instance bootstrapping
   - Auto Scaling Group with min/max capacity
   - ELB health checks with grace period
   - Instances in private subnets for security
   - SSM Agent, CloudWatch Agent, NGINX pre-installed

3. **Security Groups Module** (`modules/ec2_sg/`)
   - Dedicated security group for ASG instances
   - Ingress from ALB only (port 80)
   - Modern security group rule resources (one CIDR per rule)
   - Least privilege egress rules

4. **ALB Module** (`modules/alb/`)
   - Application Load Balancer with HTTP/HTTPS listeners
   - Target group with health checks
   - Access logs to S3 (encrypted, versioned)
   - Security groups following AWS best practices

5. **ACM Module** (`modules/acm/`)
   - SSL/TLS certificate management
   - DNS validation with automated CNAME records
   - Integration with ALB for HTTPS

6. **IAM Module** (`modules/iam/`)
   - EC2 instance roles with least privilege
   - CloudWatch Logs permissions
   - SSM Session Manager access
   - Secure assume role policies

7. **Monitoring Module** (`modules/monitoring/`)
   - S3 bucket for ALB access logs (encrypted, versioned)
   - CloudWatch Log Groups for application logs
   - CloudWatch Alarms (ASG health, ALB 5xx errors)
   - SNS topics for alerting

---

## 📁 Project Structure

```
infra/
├── terraform/
│   ├── modules/                        # Reusable Terraform modules
│   │   ├── vpc/                        # VPC, subnets, IGW, NAT, routes
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── asg/                        # Auto Scaling Group
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── asg_launch_template/        # Launch template for ASG
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variable.tf
│   │   ├── ec2_sg/                     # Security groups for instances
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── alb/                        # Application Load Balancer
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── acm/                        # ACM certificate management
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── iam/                        # IAM roles and policies
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   └── monitoring/                 # CloudWatch, S3, SNS
│   │       ├── main.tf
│   │       ├── output.tf
│   │       └── variables.tf
│   └── envs/                           # Environment-specific configurations
│       └── dev/                        # Development environment
│           ├── main.tf                 # Module composition
│           ├── locals.tf               # User data scripts
│           ├── variables.tf            # Environment variables
│           ├── outputs.tf              # Environment outputs
│           ├── backend.tf              # Remote state configuration
│           ├── providers.tf            # Provider configuration
│           ├── versions.tf             # Version constraints
│           └── terraform.tfvars        # Variable values
└── README.md
```

---

## 🚀 Terraform Best Practices Implemented

### 1. **Modular Design**
- **Separation of Concerns**: Each module handles a specific infrastructure component
- **Reusability**: Modules can be used across multiple environments
- **Composability**: Modules are composed in environment-specific root modules
- **Single Responsibility**: Each module has a clear, focused purpose

### 2. **State Management**
- **Remote State**: S3 backend for state storage
- **State Locking**: DynamoDB table for state locking (via `use_lockfile`)
- **Encryption**: State files encrypted at rest
- **Environment Isolation**: Separate state files per environment (`dev/terraform.tfstate`)

### 3. **Security Best Practices**

#### Security Groups
- **Modern Rule Resources**: Uses `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule` instead of inline rules
- **One CIDR per Rule**: Better management, tags, and descriptions
- **Least Privilege**: Specific ports and protocols only
- **Security Group References**: EC2 instances reference ALB security group for internal communication

#### IAM
- **Least Privilege**: IAM roles grant only necessary permissions
- **Service Principals**: Proper use of service principals for EC2 assume roles
- **Policy Documents**: Structured IAM policy documents using data sources
- **No Hardcoded Credentials**: All authentication via IAM roles and profiles

#### S3 Bucket Policies
- **Service Principal**: Uses `logdelivery.elasticloadbalancing.amazonaws.com` for ALB logs
- **Specific Resource Paths**: Precise resource ARNs with account ID
- **Encryption**: SSE-S3 encryption enabled
- **Versioning**: Enabled for log retention and recovery
- **Ownership Controls**: `BucketOwnerEnforced` for consistent object ownership

### 4. **Version Control**
- **Provider Versioning**: Pinned provider versions (`~> 5.30`)
- **Terraform Version**: Minimum version constraint (`>= 1.9.0, < 2.0.0`)
- **Lock Files**: `.terraform.lock.hcl` committed for reproducible builds

### 5. **Environment Management**
- **Environment Separation**: Dedicated directories per environment (`envs/dev/`)
- **Variable Files**: `terraform.tfvars` for environment-specific values
- **Consistent Naming**: Resource naming convention: `${project_name}-${environment}-${resource_type}`

### 6. **Outputs and Data Sources**
- **Explicit Outputs**: Each module exposes necessary outputs
- **Data Sources**: Uses AWS data sources for dynamic values (AMI lookup, availability zones)
- **Dependency Management**: Proper `depends_on` for resource ordering

### 7. **Code Quality**
- **Descriptions**: All variables and resources have descriptions
- **Tags**: Consistent tagging strategy across all resources
- **Comments**: User data scripts include clear section comments
- **Local Values**: Complex logic abstracted into `locals` blocks

---

## 🔒 Security Features

### Network Security
- VPC isolation with private/public subnet separation
- ASG instances in private subnets (no direct internet access)
- NAT Gateway for private subnet internet egress
- Security groups with explicit ingress/egress rules
- No SSH access from internet (SSM Session Manager instead)
- ALB security group allows HTTP/HTTPS from internet
- EC2 security group allows HTTP only from ALB (security group referencing)

### Access Control
- IAM roles with least privilege policies
- EC2 instances use instance profiles (no access keys)
- SSM Session Manager for secure shell access
- CloudWatch Logs permissions scoped to specific log groups

### Data Protection
- S3 bucket encryption (SSE-S3)
- S3 bucket versioning enabled
- S3 bucket policies with service principals
- CloudWatch Logs retention policies

### Monitoring & Alerting
- CloudWatch Alarms for CPU utilization
- ALB 5xx error monitoring
- SNS email notifications
- ALB access logs to S3 for audit trails

---

## 📊 Monitoring & Observability

### CloudWatch Logs
- EC2 application logs (`/app/${project_name}/${environment}/ec2`)
- NGINX access and error logs via CloudWatch Agent
- 14-day log retention policy

### CloudWatch Metrics & Alarms
- **ASG Health Alarm**: Triggers when in-service instances < 1 (insufficient capacity)
- **ALB 5xx Alarm**: Triggers on any 5xx error from the load balancer
- **SNS Notifications**: Email alerts sent to configured recipients

### S3 Access Logs
- ALB access logs stored in S3
- Logs path: `s3://bucket-name/alb-access-logs/AWSLogs/account-id/*`
- Encrypted and versioned for compliance

---

## 🛠️ Prerequisites

- **Terraform**: >= 1.9.0, < 2.0.0
- **AWS CLI**: Configured with appropriate credentials
- **AWS Account**: With necessary permissions
- **SSH Key Pair**: For EC2 instance access (optional, SSM preferred)

### AWS Permissions Required

The Terraform execution role/user needs permissions for:
- VPC, EC2, IAM, ALB, S3, CloudWatch, SNS
- S3 bucket creation (for state backend)
- DynamoDB table creation (for state locking)

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd infra
```

### 2. Configure AWS Credentials

```bash
# Using AWS profiles (recommended)
aws configure --profile terraform

# Or set environment variables
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=ap-south-1
```

### 3. Initialize Terraform Backend

Ensure your S3 backend bucket exists:

```bash
aws s3 mb s3://zain-terraform-state-ap-south-1 --region ap-south-1
```

### 4. Configure Environment Variables

Edit `terraform/envs/dev/terraform.tfvars`:

```hcl
project_name = "terraform-platform"
environment  = "dev"
alert_email  = "your-email@example.com"
```

### 5. Initialize Terraform

```bash
cd terraform/envs/dev
terraform init
```

### 6. Plan Infrastructure Changes

```bash
terraform plan
```

### 7. Apply Infrastructure

```bash
terraform apply
```

### 8. View Outputs

```bash
terraform output
```

---

## 📝 Configuration

### Environment Variables

Edit `terraform/envs/dev/terraform.tfvars`:

```hcl
project_name = "your-project-name"
environment  = "dev"
alert_email  = "alerts@example.com"
```

### Module Variables

Each module accepts variables for customization. Key variables:

- **VPC Module**: `vpc_cidr` (default: `10.0.0.0/16`)
- **ASG Module**: `min_size`, `max_size`, `desired_capacity`, `private_subnet_ids`
- **Launch Template Module**: `instance_type`, `instance_profile_name`, `ec2_sg_id`, `user_data`
- **ALB Module**: `target_port` (default: `80`), `log_bucket`, `site_cert`
- **ACM Module**: `domain_name`, `alb_dns_name`, `zone_id`
- **Monitoring Module**: `asg_name`, `alb_arn_suffix`, `alert_email`

---

## 🔄 CI/CD Integration (Planned)

This infrastructure is designed for CI/CD integration. Recommended pipeline stages:

1. **Validate**: `terraform validate`
2. **Format Check**: `terraform fmt -check`
3. **Security Scan**: `tfsec` or `checkov`
4. **Plan**: `terraform plan -out=tfplan`
5. **Review**: Manual approval gate
6. **Apply**: `terraform apply tfplan`
7. **Smoke Tests**: Verify infrastructure health

### Example GitHub Actions Workflow

```yaml
name: Terraform CI/CD

on:
  push:
    branches: [main]
  pull_request:

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - name: Terraform Init
        run: terraform init
      - name: Terraform Validate
        run: terraform validate
      - name: Terraform Plan
        run: terraform plan
```

---

## 🧪 Testing

### Manual Testing

1. **Verify ALB**: Access ALB DNS name via HTTP/HTTPS
2. **Check ASG**: Verify instances are healthy and in-service
3. **Test Auto Scaling**: Terminate an instance, verify ASG replaces it
4. **Test Monitoring**: Trigger alarms and verify SNS notifications
5. **Validate Logs**: Check CloudWatch Logs and S3 access logs
6. **HTTPS Certificate**: Verify ACM certificate is issued and ALB serves HTTPS

### Terraform Commands

```bash
# Validate configuration
terraform validate

# Format code
terraform fmt

# Check for errors
terraform plan

# Show current state
terraform show
```

---

## 📚 Key Learnings & Best Practices Demonstrated

### Infrastructure as Code
- Declarative infrastructure definition
- Version-controlled infrastructure changes
- Reproducible deployments
- Infrastructure documentation as code

### AWS Services Integration
- VPC networking with public/private subnets and NAT Gateway
- Auto Scaling Groups with launch templates
- Application Load Balancer with target groups
- ACM for SSL/TLS certificate management
- CloudWatch monitoring and alerting
- S3 for log storage with bucket policies
- IAM for access control

### Terraform Advanced Features
- Module composition and reusability
- Data sources for dynamic values
- Local values for code organization
- Remote state management
- Provider versioning and constraints

### Production Readiness
- Auto Scaling for high availability and fault tolerance
- Multi-AZ deployment with private subnets
- Security hardening (security groups, IAM, private subnets)
- Monitoring and alerting (ASG health, ALB errors)
- Log aggregation and retention
- Encryption at rest (S3 logs)
- HTTPS/TLS with ACM

---

## 🗺️ Roadmap

- [x] Add Auto Scaling Groups with launch templates
- [x] Multi-AZ deployment with private subnets
- [x] ACM certificate management for HTTPS
- [x] NAT Gateway for private subnet egress
- [ ] Add CI/CD pipeline (GitHub Actions / GitLab CI)
- [ ] Implement Terraform workspaces for environment management
- [ ] Add automated testing (Terratest)
- [ ] Implement blue-green deployments
- [ ] Implement RDS database module
- [ ] Add WAF integration for ALB
- [ ] Implement CloudFront CDN
- [ ] Add disaster recovery procedures
- [ ] Cost optimization recommendations

---

## 🤝 Contributing

This is a learning project demonstrating production-grade Terraform practices. Contributions and suggestions are welcome!

### Contribution Guidelines

1. Follow Terraform best practices
2. Maintain module reusability
3. Add descriptions to all variables and resources
4. Update documentation for any changes
5. Test changes in dev environment first

---

## 📄 License

This project is for educational and demonstration purposes.

---

## 👤 Author

**Zain Malik**

- Demonstrating production-grade Terraform infrastructure
- Following AWS Well-Architected Framework principles
- Implementing Infrastructure as Code best practices

---

## 🙏 Acknowledgments

- HashiCorp Terraform documentation
- AWS Well-Architected Framework
- Terraform community best practices
- AWS documentation and examples

---

## 📞 Support

For questions or issues:
1. Review Terraform documentation
2. Check AWS service documentation
3. Review module-specific README files (if available)

---

**Last Updated**: January 2026

**Terraform Version**: >= 1.9.0, < 2.0.0

**AWS Provider Version**: ~> 5.30

---

*This project demonstrates enterprise-level Terraform practices suitable for production environments. Always review and customize configurations according to your organization's security and compliance requirements.*
