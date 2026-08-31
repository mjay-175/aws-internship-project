# AWS Internship Project

Custom VPC + EC2 Web Application + S3 Storage + IAM Roles + CloudWatch Monitoring + Automated Backup and Cost Control, built entirely within AWS Free Tier limits.

## Status

In progress. See [progress log](docs/progress-log.md) for phase-by-phase detail.

## Architecture

```
[ IAM User ]
   |
   v
[ Custom VPC (10.0.0.0/16) + Public Subnet (10.0.1.0/24) + Internet Gateway ]
   |
   v
[ EC2 t3.micro (Ubuntu) + Apache web server ]
   |            |
   | IAM Role   | Security Group (SSH: own IP only, HTTP: public)
   v            v
[ S3 Bucket ]  [ Access Control ]
   |
   +--> CloudWatch Metrics/Logs --> Alarms --> SNS Email
   |
   +--> EBS Snapshot Backup
   |
   +--> AWS Budgets Alert
```

## What's built so far

- **IAM**: Dedicated non-root admin user (`malavika-admin`) in an `InternDevelopers` group with a custom least-privilege policy (not `AdministratorAccess`). Separate EC2 instance role for S3 access — no hardcoded access keys on the instance. Both policies were iterated from a broad starting point down to bucket-scoped permissions (see `iam/`).
- **VPC**: Custom VPC with a public subnet, Internet Gateway, and route table — built manually (not the all-in-one wizard) to understand each networking primitive.
- **EC2**: Ubuntu web server running Apache, deployed inside the custom VPC, reachable over HTTP, SSH restricted to a single IP.
- **S3**: Private bucket (SSE-S3 encryption, ACLs disabled, versioning off — appropriate for a demo project, not a production data store) used for asset/log storage, accessed via IAM role rather than public access or embedded credentials.
- **EBS Snapshot**: Backup of the EC2 root volume taken; restore plan documented below.

## Restore plan (EBS snapshot)

To restore from the snapshot: create a new EBS volume from the snapshot in the same Availability Zone, then either (a) attach it to a new/existing EC2 instance as the root volume, or (b) create an AMI from the snapshot and launch a new instance from that AMI.

## Free Tier safety

- Single t3.micro EC2 instance only
- No NAT Gateway / Application Load Balancer / RDS / Auto Scaling
- S3 used only for small demo files and logs
- Resources tagged for tracking and cleanup

## Repo structure

```
iam/       IAM policy JSON (group policy + EC2 role policy)
app/       Demo web application files
scripts/   Log sync + log analysis scripts
docs/      Architecture notes, screenshots, progress log
data/      Sample access-log dataset
```
