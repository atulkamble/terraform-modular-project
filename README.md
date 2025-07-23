### ✅ What Are Terraform Modules?

In Terraform, **modules** are reusable, encapsulated blocks of Terraform configuration code. Think of a module as a function in programming: it accepts inputs (variables), performs a task (resources), and returns outputs.

---

### 💡 Why Use Terraform Modules?

| Benefit             | Explanation                                                                                 |
| ------------------- | ------------------------------------------------------------------------------------------- |
| 🔁 **Reusability**  | Write code once, use it everywhere (e.g., an EC2 module for dev, test, prod).               |
| 📦 **Organization** | Break large projects into smaller, logical components like `vpc`, `ec2`, `rds`, etc.        |
| 🧪 **Isolation**    | Each module can be tested and developed independently.                                      |
| ⛏️ **Abstraction**  | Hide complexity. Consumers of the module don’t need to understand the internals.            |
| 🚀 **Scalability**  | Enables DevOps teams to scale infrastructure across environments with minimal code changes. |

---

### 🔧 How Modules Work (Basic Anatomy)

A module consists of:

* `main.tf` – defines resources
* `variables.tf` – defines inputs
* `outputs.tf` – defines outputs

---

### 📂 Types of Modules

1. **Root Module**
   The primary entry point in your Terraform project (where you run `terraform init`, `apply`, etc.)

2. **Child Modules**
   Referenced inside the root module using `module "xyz" { source = "./path" }`

3. **Remote Modules**
   Modules pulled from:

   * GitHub (`source = "git::https://github.com/org/repo.git//vpc"`)
   * Terraform Registry (`source = "terraform-aws-modules/vpc/aws"`)

---

### 🔁 Example Use Case: Without vs With Module

**Without Module (Repetition):**

```hcl
resource "aws_instance" "dev" {
  ami           = "ami-abc"
  instance_type = "t2.micro"
}

resource "aws_instance" "prod" {
  ami           = "ami-abc"
  instance_type = "t2.medium"
}
```

**With Module (Reusable):**

```hcl
module "dev" {
  source         = "./modules/ec2"
  ami_id         = "ami-abc"
  instance_type  = "t2.micro"
}

module "prod" {
  source         = "./modules/ec2"
  ami_id         = "ami-abc"
  instance_type  = "t2.medium"
}
```

---

### 📌 When Should You Use Modules?

✅ Use modules when:

* You’re repeating code across environments
* You want to build reusable components (e.g., `ec2`, `s3`, `rds`, `vpc`)
* Your infrastructure is growing and needs to be organized

---


## ✅ Modules Included

* **VPC**: Custom VPC with public subnet and internet gateway
* **Security Group (SG)**: Allow SSH and HTTP
* **EC2**: Launch Amazon Linux EC2 instance
* **S3**: Create an S3 bucket
* **RDS**: Provision MySQL RDS instance (optional for local testing)

---

## 📁 Directory Structure

```bash
terraform-modular-project/
├── main.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security-group/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── s3/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── rds/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## 🧩 Root Module Files

### `providers.tf`

```hcl
provider "aws" {
  region = "us-east-1"
}
```

---

### `main.tf`

```hcl
module "vpc" {
  source       = "./modules/vpc"
  vpc_cidr     = var.vpc_cidr
  subnet_cidr  = var.subnet_cidr
}

module "sg" {
  source     = "./modules/security-group"
  vpc_id     = module.vpc.vpc_id
}

module "ec2" {
  source                  = "./modules/ec2"
  ami_id                  = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = module.vpc.subnet_id
  vpc_security_group_ids  = [module.sg.sg_id]
  instance_name           = var.instance_name
}

module "s3" {
  source     = "./modules/s3"
  bucket_name = var.bucket_name
}

module "rds" {
  source              = "./modules/rds"
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  subnet_ids          = [module.vpc.subnet_id]
  vpc_security_group_ids = [module.sg.sg_id]
}
```

---

### `variables.tf`

```hcl
variable "vpc_cidr"       { default = "10.0.0.0/16" }
variable "subnet_cidr"    { default = "10.0.1.0/24" }
variable "ami_id"         { default = "ami-0c55b159cbfafe1f0" }
variable "instance_type"  { default = "t2.micro" }
variable "instance_name"  { default = "ModularEC2" }
variable "bucket_name"    { default = "my-terraform-modular-bucket-001" }

variable "db_name"        { default = "mydb" }
variable "db_username"    { default = "admin" }
variable "db_password"    { default = "password12345" }
```

---

### `outputs.tf`

```hcl
output "ec2_public_ip" {
  value = module.ec2.public_ip
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}
```

---

### `terraform.tfvars`

```hcl
instance_name = "DemoInstance"
bucket_name   = "atul-tf-modular-s3"
```

---

## 🧱 Modules

---

### 1. **VPC Module**

**`modules/vpc/main.tf`**

```hcl
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = { Name = "ModularVPC" }
}

resource "aws_subnet" "this" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "r" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.rt.id
}
```

**`variables.tf`**

```hcl
variable "vpc_cidr" {}
variable "subnet_cidr" {}
```

**`outputs.tf`**

```hcl
output "vpc_id"     { value = aws_vpc.this.id }
output "subnet_id"  { value = aws_subnet.this.id }
```

---

### 2. **Security Group Module**

**`modules/security-group/main.tf`**

```hcl
resource "aws_security_group" "this" {
  name        = "allow-ssh-http"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

**`variables.tf`**

```hcl
variable "vpc_id" {}
```

**`outputs.tf`**

```hcl
output "sg_id" {
  value = aws_security_group.this.id
}
```

---

### 3. **EC2 Module**

**`modules/ec2/main.tf`**

```hcl
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  tags = {
    Name = var.instance_name
  }
}
```

**`variables.tf`**

```hcl
variable "ami_id" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "vpc_security_group_ids" {
  type = list(string)
}
variable "instance_name" {}
```

**`outputs.tf`**

```hcl
output "public_ip" {
  value = aws_instance.this.public_ip
}
```

---

### 4. **S3 Module**

**`modules/s3/main.tf`**

```hcl
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  force_destroy = true
}
```

**`variables.tf`**

```hcl
variable "bucket_name" {}
```

**`outputs.tf`**

```hcl
output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}
```

---

### 5. **RDS Module (MySQL)**

**`modules/rds/main.tf`**

```hcl
resource "aws_db_subnet_group" "this" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "this" {
  identifier              = "mydb-instance"
  engine                  = "mysql"
  instance_class          = "db.t2.micro"
  allocated_storage       = 20
  name                    = var.db_name
  username                = var.db_username
  password                = var.db_password
  vpc_security_group_ids  = var.vpc_security_group_ids
  db_subnet_group_name    = aws_db_subnet_group.this.name
  skip_final_snapshot     = true
}
```

**`variables.tf`**

```hcl
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "subnet_ids" {
  type = list(string)
}
variable "vpc_security_group_ids" {
  type = list(string)
}
```

**`outputs.tf`**

```hcl
output "db_endpoint" {
  value = aws_db_instance.this.endpoint
}
```

---

## 🚀 Deployment Steps

### 1. Initialize the Project

```bash
cd terraform-modules-practice
terraform init
```

---

### 2. Review the Plan

```bash
terraform plan
```

---

### 3. Apply the Configuration

```bash
terraform apply -auto-approve
```

---

### 4. Destroy Resources (if needed)

```bash
terraform destroy -auto-approve
```

---
