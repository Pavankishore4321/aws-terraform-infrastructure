# ─────────────────────────────────────────────────────────────────────────────
# Module: S3 Bucket
# Project: AspTax (Incresol Software Services)
# Creates: S3 bucket with versioning, encryption, lifecycle rules
# Use case: Static assets storage, application backups
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "main" {
  bucket = "${var.project}-${var.env}-${var.bucket_suffix}"

  tags = {
    Name        = "${var.project}-${var.env}-bucket"
    Environment = var.env
    Project     = var.project
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle: move old files to cheaper storage
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "archive-old-backups"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}
