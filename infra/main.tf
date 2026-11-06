terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.common_tags, {
    Name = "internship-vpc"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = merge(var.common_tags, {
    Name = "internship-public-subnet"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.common_tags, {
    Name = "internship-igw"
  })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.common_tags, {
    Name = "internship-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "ec2_sg" {
  name        = "internship-ec2-sg"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from specific IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ip]
  }

  ingress {
    description = "HTTP from anywhere"
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

  tags = merge(var.common_tags, {
    Name = "internship-ec2-sg"
  })
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "EC2-S3-InternshipRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = merge(var.common_tags, {
    Name = "EC2-S3-InternshipRole"
  })
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "S3AccessPolicy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2-S3-InternshipProfile"
  role = aws_iam_role.ec2_role.name
  tags = merge(var.common_tags, {
    Name = "EC2-S3-InternshipProfile"
  })
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 -y
              systemctl enable apache2
              systemctl start apache2
              echo "<h1>AWS Internship Project Demo</h1>" > /var/www/html/index.html
              EOF

  tags = merge(var.common_tags, {
    Name = "internship-web-server"
  })
}

resource "aws_s3_bucket" "internship_bucket" {
  bucket = var.bucket_name
  tags = merge(var.common_tags, {
    Name = "internship-bucket"
  })
}

resource "aws_s3_bucket_public_access_block" "internship_bucket_bpa" {
  bucket = aws_s3_bucket.internship_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "internship_bucket_sse" {
  bucket = aws_s3_bucket.internship_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
