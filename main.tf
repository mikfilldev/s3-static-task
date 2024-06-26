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
