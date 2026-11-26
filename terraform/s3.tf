# S3 bucket for URLs
resource "aws_s3_bucket" "url_storage_bucket" {
  bucket = "${var.project_name}-url-storage-bucket"
  force_destroy = true # Allow terraform to destroy the bucket even with files inside

  tags = {
    Name = "${var.project_name}-url-storage-bucket"
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "bucket_public_access_rules" {
  bucket = aws_s3_bucket.url_storage_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable bucket versioning to restore previous file versions
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.url_storage_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Apply bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryptions" {
  bucket = aws_s3_bucket.url_storage_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}