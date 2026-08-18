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

variable "instance_type_dev" {
  description = "EC2 instance type for development"
  type        = string
  default     = "t3.medium"
}

variable "instance_type_prod" {
  description = "EC2 instance type for production"
  type        = string
  default     = "t3.large"
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
}
