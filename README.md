# aws-terraform-infrastructure

Terraform modules to provision AWS infrastructure for **AspTax** and
other projects at **Incresol Software Services**. Written as Infrastructure
as Code (IaC) to replicate the AWS environment that was managed manually in production.

---

## Repository Structure

```
aws-terraform-infrastructure/
├── modules/
│   ├── vpc/                    # VPC, subnets, IGW, NAT, route tables
│   ├── ec2/                    # EC2, security groups, launch template, ASG
│   ├── alb/                    # Application Load Balancer, target group, listeners
│   ├── rds/                    # RDS MySQL/PostgreSQL, subnet group, security group
│   ├── efs/                    # EFS shared file system, mount targets
│   └── s3/                     # S3 bucket with versioning, encryption, lifecycle
├── environments/
│   ├── dev/
│   │   ├── main.tf             # Calls all modules for dev environment
│   │   ├── variables.tf
│   │   └── terraform.tfvars    # Dev-specific variable values
│   └── prod/
│       ├── main.tf             # Calls all modules for prod (larger sizing)
│       ├── variables.tf
│       └── terraform.tfvars    # Prod-specific variable values
└── README.md
```

---

## Architecture Overview

```
                    Internet
                       │
               ┌───────▼────────┐
               │   ALB (public) │  ← ports 80/443
               └───────┬────────┘
                        │
          ┌─────────────▼─────────────┐
          │     Auto Scaling Group     │
          │  EC2 instances (private)   │  ← app servers
          └──────┬──────────┬─────────┘
                 │          │
         ┌───────▼──┐  ┌────▼────┐
         │  RDS DB  │  │   EFS   │  ← shared file storage
         │  MySQL   │  │ /shared │
         └──────────┘  └─────────┘
                 │
         ┌───────▼──────┐
         │  S3 Bucket   │  ← assets, backups
         └──────────────┘
```

---

## Module Details

### vpc
Creates the full network layer:
- VPC with custom CIDR
- Public subnets (for ALB and NAT Gateway)
- Private subnets (for EC2 and RDS — not directly accessible from internet)
- Internet Gateway
- NAT Gateway (lets private EC2 reach internet for updates)
- Route tables with correct associations

### ec2
Creates application servers with auto scaling:
- Security group — allows traffic only from ALB
- Launch template with Ubuntu AMI, Docker, Nginx user-data
- Auto Scaling Group — scales between min/max based on load
- IAM role with CloudWatch and S3 access (least-privilege)

### alb
Creates the Application Load Balancer:
- ALB in public subnets
- Target group pointing to EC2 instances
- HTTP listener → redirects to HTTPS
- HTTPS listener → forwards to target group
- Health checks on `/health` endpoint

### rds
Creates managed database:
- MySQL 8.0 or PostgreSQL 14
- Deployed in private subnets (no public access)
- Multi-AZ enabled in production (automatic failover)
- Automated backups with 7-day retention
- Deletion protection enabled in prod

### efs
Creates shared file system:
- EFS mount targets in each private subnet
- Security group allows NFS (port 2049) from app servers only
- Used for shared uploads/files across multiple EC2 instances

### s3
Creates object storage bucket:
- Versioning enabled
- Server-side encryption (AES256)
- Public access fully blocked
- Lifecycle rules: Standard → Standard-IA (30d) → Glacier (90d) → Delete (365d)

---

## Dev vs Prod Comparison

| Resource | Dev | Prod |
|---|---|---|
| EC2 instance type | t3.small | t3.medium |
| ASG min/max | 1 / 2 | 2 / 4 |
| RDS instance | db.t3.micro | db.t3.small |
| RDS Multi-AZ | No | Yes |
| RDS backup retention | 1 day | 7 days |
| Deletion protection | No | Yes |

---

## How to Use

### Prerequisites
```bash
# Install Terraform
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Configure AWS credentials
aws configure
# AWS Access Key ID: your-key
# AWS Secret Access Key: your-secret
# Default region: ap-south-1
```

### Deploy Dev Environment
```bash
cd environments/dev

# Initialise — downloads AWS provider
terraform init

# Preview what will be created
terraform plan

# Create infrastructure
terraform apply

# Destroy when done
terraform destroy
```

### Deploy Prod Environment
```bash
cd environments/prod
terraform init
terraform plan
terraform apply
```

---

## Real AWS Resources This Represents

These Terraform modules provision the same AWS infrastructure that was
managed manually at Incresol for the **AspTax** project:

| AWS Service | Used For |
|---|---|
| EC2 (t3.medium) | Angular + Spring Boot app servers |
| ALB / NLB | Load balancing across app servers |
| Auto Scaling Group | Handle traffic spikes automatically |
| RDS MySQL | Application database |
| EFS | Shared file storage across EC2 instances |
| S3 | Static assets, build artifacts, backups |
| IAM | Least-privilege roles for EC2, Jenkins |
| CloudWatch | Monitoring, logs, CPU/memory alerts |
| VPC | Network isolation, private subnets |

---

## Security Notes

- RDS is in **private subnets** — no direct internet access
- EC2 instances are in **private subnets** — only accessible via ALB
- SSH access restricted to admin CIDR — never `0.0.0.0/0` in production
- All EBS volumes and RDS storage are **encrypted**
- S3 bucket has **public access fully blocked**
- IAM roles follow **least-privilege principle**

---

## Author

**Pavan Kishore Nakka**
DevOps & Cloud Engineer | 3+ Years Experience
AWS Certified Solutions Architect – Associate | AWS Certified Cloud Practitioner

[LinkedIn](https://www.linkedin.com/in/nakka-pavan-kishore)
