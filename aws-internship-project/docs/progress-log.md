# AWS Internship Project — Progress Log

**Status legend:** ⬜ not started | 🟨 in progress | ✅ done

## Phase 1 — Account & IAM Foundation ✅
- ✅ Daily-use IAM user created: `malavika-admin`
- ✅ Group created: `InternDevelopers` (single group used — CloudOperators skipped as unnecessary for solo project scope)
- ✅ Custom policy `InternshipProjectPolicy` (EC2 full, CloudWatch, SNS, Budgets view, S3 list/get/put) attached to group
- ✅ EC2 instance role `EC2-S3-InternshipRole` created (temporarily AmazonS3FullAccess — to be scoped to project bucket only in Phase 4)

## Phase 2 — Networking (Custom VPC) ✅
- ✅ VPC created (10.0.0.0/16) — `internship-vpc`
- ✅ Public subnet created (10.0.1.0/24) — `internship-public-subnet`
- ✅ Internet Gateway created and attached — `internship-igw`
- ✅ Route table configured (0.0.0.0/0 → IGW), subnet associated (used the VPC's auto-created main route table, not the default VPC's)
- ✅ Auto-assign public IP enabled on subnet
- ✅ Resources tagged (Project/Env/Owner)

## Phase 3 — Compute & Application ✅ (traffic gen still pending)
- ✅ EC2 launched: `internship-web-server`, t3.micro, Ubuntu 24.04, in internship-vpc/internship-public-subnet
- ✅ Key pair `internship-key.pem`, security group `internship-web-sg` (SSH from own IP only, HTTP from anywhere)
- ✅ IAM instance profile `EC2-S3-InternshipRole` attached
- ✅ Apache installed and enabled, demo "Student Portal" page deployed
- ✅ Verified via browser at public IP (52.66.195.17)
- ⬜ Traffic generated for logs (will happen naturally + Phase 6 log analysis)

## Phase 4 — Storage (S3 + EBS Snapshot) 🟨 (dataset/log-sync pending — done in Phase 6)
- ✅ S3 bucket created (private, SSE-S3 encryption, ACLs disabled, versioning off): `malavika-internship-bucket-2026`
- ✅ EC2 role scoped from AmazonS3FullAccess down to bucket-specific inline policy (`EC2-S3-BucketScopedPolicy`)
- ✅ IAM group policy (`InternshipProjectPolicy`) also scoped: split `s3:ListAllMyBuckets` (account-wide) from bucket-scoped list/get/put actions
- ✅ EBS snapshot taken of `internship-web-server` root volume
- ⬜ Static assets + sample dataset upload, log sync script (Phase 6)
- Restore plan (documented): create new EBS volume from snapshot in same AZ, attach as root volume to new/existing instance, or create AMI from snapshot and launch new instance from it

## Phase 5 — Monitoring, Alerts, Cost Control
- ⬜ CloudWatch alarms (CPU >70%, StatusCheckFailed)
- ⬜ SNS topic + email confirmed
- ⬜ (Optional) Apache logs → CloudWatch Logs
- ⬜ AWS Budget alert set
- ⬜ Alert validated via controlled load test

## Phase 6 — Log Analysis & Validation
- ⬜ Analysis script run on sample logs
- ⬜ Output captured
- ⬜ IAM denial case validated
- ⬜ Cleanup checklist validated

## Notes / actual results (fill in as we go)
_(nothing recorded yet)_
