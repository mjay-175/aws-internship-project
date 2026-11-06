#!/bin/bash
set -euo pipefail

# ==============================================================================
# WARNING: DESTRUCTIVE SCRIPT
# This script deletes AWS resources created for the internship project.
# ==============================================================================

REGION="ap-south-1"
DRY_RUN=true
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [[ "${1:-}" == "--execute" ]]; then
    DRY_RUN=false
    echo -e "${RED}WARNING: Executing in destructive mode. Resources WILL be deleted.${NC}"
else
    echo -e "${GREEN}Running in DRY-RUN mode. Pass --execute to actually delete.${NC}"
fi

function delete_resource() {
    local resource_type=$1
    local resource_name=$2
    local delete_command=$3
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${GREEN}[DRY RUN] Would delete ${resource_type}: ${resource_name}${NC}"
    else
        echo -e "${RED}[EXECUTE] Deleting ${resource_type}: ${resource_name}...${NC}"
        # Execute the command, evaluating it
        eval "$delete_command" || echo -e "${YELLOW}Failed to delete ${resource_type}: ${resource_name}${NC}"
    fi
}

echo "Starting cleanup in region ${REGION}..."

# 1. Terminate EC2 instance
INSTANCE_ID=$(aws ec2 describe-instances --region $REGION --filters "Name=tag:Name,Values=internship-web-server" "Name=instance-state-name,Values=running,stopped" --query "Reservations[].Instances[].InstanceId" --output text)
if [ -n "$INSTANCE_ID" ] && [ "$INSTANCE_ID" != "None" ]; then
    delete_resource "EC2 Instance" "$INSTANCE_ID" "aws ec2 terminate-instances --region $REGION --instance-ids $INSTANCE_ID"
    
    if [ "$DRY_RUN" = false ]; then
        echo "Waiting for instance $INSTANCE_ID to terminate..."
        aws ec2 wait instance-terminated --region $REGION --instance-ids $INSTANCE_ID
    fi
fi

# 2-12: Simulated placeholders for dry run output (in a real script you would query IDs)
delete_resource "Security Group" "internship-web-sg" "aws ec2 delete-security-group --region $REGION --group-name internship-web-sg"
delete_resource "Subnet" "tag:Name=internship-subnet" "echo 'aws ec2 delete-subnet...'"
delete_resource "IGW" "tag:Name=internship-igw" "echo 'aws ec2 detach-internet-gateway... && aws ec2 delete-internet-gateway...'"
delete_resource "Route Table" "tag:Name=internship-rt" "echo 'aws ec2 delete-route-table...'"
delete_resource "VPC" "tag:Name=internship-vpc" "echo 'aws ec2 delete-vpc...'"
delete_resource "S3 Bucket" "malavika-internship-bucket-2026" "aws s3 rm s3://malavika-internship-bucket-2026 --recursive && aws s3api delete-bucket --bucket malavika-internship-bucket-2026 --region $REGION"
delete_resource "CloudWatch Alarm" "internship-cpu-alarm" "echo 'aws cloudwatch delete-alarms...'"
delete_resource "SNS Topic" "internship-alerts" "echo 'aws sns delete-topic...'"
delete_resource "IAM Profile/Role" "internship-role" "echo 'aws iam delete-instance-profile... && aws iam delete-role...'"
delete_resource "EBS Snapshots" "tag:Project=internship" "echo 'aws ec2 delete-snapshot...'"

echo "Cleanup script finished."
