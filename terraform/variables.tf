variable "aws_region" {
  description = "AWS region for deploying regional infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "az1" {
  description = "Availability zone 1"
  type        = string
  default     = "us-east-1a"
}

variable "az2" {
  description = "Availability zone 2"
  type        = string
  default     = "us-east-1b"
}

variable "project_name" {
  description = "Project prefix used for resource naming and tags"
  type        = string
  default     = "uptime-checker"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.0.0/27"
}

variable "private_subnet_a_cidr" {
  description = "CIDR block for private subnet 1"
  type        = string
  default     = "10.0.0.32/27"
}

variable "private_subnet_b_cidr" {
  description = "CIDR block for private subnet 2"
  type        = string
  default     = "10.0.0.64/27"
}
