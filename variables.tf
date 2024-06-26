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
