variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnet"
  type        = string
  default     = "ap-south-1a"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "internship-key"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "malavika-internship-bucket-2026"
}

variable "ssh_ip" {
  description = "IP address allowed for SSH access"
  type        = string
  default     = "36.255.14.130/32"
}

variable "alert_email" {
  description = "Email address for SNS alerts"
  type        = string
  default     = "malavika.jayaraj@gmail.com"
}

variable "budget_amount" {
  description = "Monthly budget amount"
  type        = string
  default     = "5.0"
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project = "InternshipAWS"
    Env     = "Demo"
    Owner   = "Malavika"
  }
}
