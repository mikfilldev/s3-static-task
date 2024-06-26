# Terraform AWS S3 Static Website Deployment

This guide will help you deploy a static website using AWS S3 and Terraform.

## Prerequisites

1. AWS account
2. IAM user with programmatic access
3. AWS CLI installed and configured
4. Terraform installed

## Steps

### 1. Go to AWS Console

Navigate to the [AWS Management Console](https://aws.amazon.com/console/).

### 2. Create an IAM User for Terraform Actions

Create a new IAM user with programmatic access by following this video tutorial: [AWS Made Easy - Create IAM User](https://www.youtube.com/watch?v=4ZCrRbPR3gc&ab_channel=AWSMadeEasy).

### 3. Install AWS CLI and Configure

Install the AWS CLI by following the [official AWS CLI installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

After installation, configure the AWS CLI using the credentials created in the previous step:

```sh
aws configure
```

Provide the following details:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (e.g., `eu-central-1`)
- Default output format (e.g., `json`)

### 4. Edit `variables.tf` and `main.tf`

If you wish to change the names of the resources, edit the `variables.tf` and `main.tf` files accordingly.

### 5. Terraform Plan

Initialize Terraform and create an execution plan:

```sh
terraform init
terraform plan
```

### 6. Terraform Apply

Apply the Terraform configuration to create the resources:

```sh
terraform apply
```

### 7. Check Your Deployed Webpage

Once the Terraform apply is complete, you can check your deployed static website at the following URLs (replace with your bucket name if you changed it):

- [http://mik-test1-s3.s3-website.eu-central-1.amazonaws.com/](http://mik-test1-s3.s3-website.eu-central-1.amazonaws.com/)
- [http://mik-test1-s3.s3-website.eu-central-1.amazonaws.com/error.html](http://mik-test1-s3.s3-website.eu-central-1.amazonaws.com/error.html)

## File Structure

### `variables.tf`

Define the variables used in the Terraform configuration:

```hcl
variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "eu-central-1"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "mik-test1-s3"
}

variable "s3_log_bucket_name" {
  description = "The name of the S3 log bucket"
  type        = string
  default     = "mik-test1-log-bucket"
}

variable "index_html_source" {
  description = "Path to the index.html file"
  type        = string
  default     = "s3_files/html/index.html"
}

variable "error_html_source" {
  description = "Path to the error.html file"
  type        = string
  default     = "s3_files/html/error.html"
}
```

### `main.tf`

Terraform configuration for creating and configuring the S3 buckets:

```hcl
provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "mik-test1-s3" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "Static Website Bucket"
    Environment = "Test"
  }
}

resource "aws_s3_bucket" "mik-test1-s3-log-bucket" {
  bucket = var.s3_log_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "mik-test1-controls-log" {
  bucket = aws_s3_bucket.mik-test1-s3-log-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "mik-test1-public_access-log" {
  bucket = aws_s3_bucket.mik-test1-s3-log-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "mik-test1-s3-log-bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.mik-test1-controls-log,
    aws_s3_bucket_public_access_block.mik-test1-public_access-log,
  ]

  bucket = aws_s3_bucket.mik-test1-s3-log-bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "mik-tes1-s3-logging" {
  bucket = aws_s3_bucket.mik-test1-s3.id

  target_bucket = aws_s3_bucket.mik-test1-s3-log-bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_versioning" "mik-test1-s3-versioning" {
  bucket = aws_s3_bucket.mik-test1-s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "mik-test1-controls" {
  bucket = aws_s3_bucket.mik-test1-s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "mik-test1-public_access" {
  bucket = aws_s3_bucket.mik-test1-s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "mik-test1-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.mik-test1-controls,
    aws_s3_bucket_public_access_block.mik-test1-public_access,
  ]

  bucket = aws_s3_bucket.mik-test1-s3.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mik-test1-s3.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "mik-test1-public_read_policy" {
  bucket = aws_s3_bucket.mik-test1-s3.bucket

  policy = <<POLICY
  {
  "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.s3_bucket_name}/*"
    }
    ]
  }
  POLICY
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.mik-test1-s3.bucket
  key          = "index.html"
  source       = var.index_html_source
  content_type = "text/html"
  acl          = "public-read"
}

resource "aws_s3_object" "error_html" {
  bucket       = aws_s3_bucket.mik-test1-s3.bucket
  key          = "error.html"
  source       = var.error_html_source
  content_type = "text/html"
  acl          = "public-read"
}
```

## Conclusion

By following the steps in this guide, you will have a static website hosted on AWS S3 using Terraform. Modify the `variables.tf` file to change the resource names and other configurations as needed.