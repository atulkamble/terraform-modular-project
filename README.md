## Terraform Modules — Basic Theory

A **Terraform module** is a reusable group of Terraform configuration files. Instead of writing the same EC2 configuration repeatedly, you can create an EC2 module once and reuse it for Dev, Test, and Prod.

A simple project structure can look like this:

```text
terraform-ec2-module/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── modules/
    └── ec2/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

The **root module** is the main project directory. The `modules/ec2` directory is a **child module**.

### 1. EC2 Module — `modules/ec2/main.tf`

```hcl
resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}
```

### 2. Module Variables — `modules/ec2/variables.tf`

```hcl
variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_name" {
  description = "Name of EC2 instance"
  type        = string
}
```

### 3. Module Output — `modules/ec2/outputs.tf`

```hcl
output "instance_id" {
  value = aws_instance.ec2.id
}

output "public_ip" {
  value = aws_instance.ec2.public_ip
}
```

## Root Module

### `main.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "web_server" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = var.instance_name
}
```

### `variables.tf`

```hcl
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
}
```

### `terraform.tfvars`

```hcl
aws_region    = "us-east-1"
ami_id        = "ami-xxxxxxxxxxxxxxxxx"
instance_type = "t2.micro"
instance_name = "Terraform-Web-Server"
```

Use a valid AMI ID for the region where you deploy.

### Root `outputs.tf`

```hcl
output "ec2_instance_id" {
  value = module.web_server.instance_id
}

output "ec2_public_ip" {
  value = module.web_server.public_ip
}
```

## Run the Project

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Format:

```bash
terraform fmt -recursive
```

Check the execution plan:

```bash
terraform plan
```

Deploy:

```bash
terraform apply
```

Enter:

```text
yes
```

Check output:

```bash
terraform output
```

You should see something similar to:

```text
ec2_instance_id = "i-0123456789abcdef0"
ec2_public_ip    = "54.x.x.x"
```

When finished:

```bash
terraform destroy
```

## How the Module Works

```text
terraform.tfvars
      ↓
Root variables.tf
      ↓
Root main.tf
      ↓
module "web_server"
      ↓
modules/ec2/
      ↓
aws_instance
      ↓
AWS EC2
```

For example:

```hcl
module "web_server" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = var.instance_type
  instance_name = var.instance_name
}
```

Here, `source` tells Terraform where the module exists, and the other values are **inputs passed from the root module to the EC2 module**.

The main benefit is reusability. Later you can create several environments using the same module:

```hcl
module "dev_ec2" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = "t2.micro"
  instance_name = "Dev-Server"
}

module "prod_ec2" {
  source = "./modules/ec2"

  ami_id        = var.ami_id
  instance_type = "t3.medium"
  instance_name = "Prod-Server"
}
```

So the basic concept to remember is:

```text
Variables → Module → Resource → Outputs
```

A good next project after this is **VPC + Security Group + EC2 using separate Terraform modules**, because that demonstrates real module dependencies and output passing.
