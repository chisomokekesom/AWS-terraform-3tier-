variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource tags"
  type        = string
  default     = "three-tier-app"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "adminuser"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}