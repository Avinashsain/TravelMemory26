variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for tagging and naming resources"
  type        = string
  default     = "travelmemory"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "trusted_ip" {
  description = "Your public IP in CIDR notation for SSH access (e.g., 1.2.3.4/32)"
  type        = string
  # Replace with your actual IP before deploying
  default = "0.0.0.0/0"
}

variable "public_key_path" {
  description = "Path to your SSH public key file"
  type        = string
  default     = "~/.ssh/travelmemory.pub"
}

variable "web_instance_type" {
  description = "EC2 instance type for the web server"
  type        = string
  default     = "t2.small"
}

variable "db_instance_type" {
  description = "EC2 instance type for the database server"
  type        = string
  default     = "t2.small"
}

variable "hash_key" {
  type        = string
  description = "Hash key for the DynamoDB table"
  default     = "LockID"
}