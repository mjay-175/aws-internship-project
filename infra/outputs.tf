output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ec2_instance_id" {
  description = "Instance ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.internship_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.internship_bucket.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.alerts.arn
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ec2_sg.id
}
