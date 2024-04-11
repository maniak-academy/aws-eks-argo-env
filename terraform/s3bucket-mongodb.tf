resource "aws_s3_bucket" "backup_bucket" {
  bucket = "sebbycorp-mongodb-backups3" # Ensure this is globally unique
  acl    = "public-read"

  # Prevent accidental bucket destruction
  lifecycle {
    prevent_destroy = true
  }

  # Optionally, include tags directly here if not using a variable
  tags = {
    "Name" = "MongoDB Backup Bucket"
    "Environment" = "Production"
  }
}

resource "aws_s3_bucket_policy" "backup_bucket_policy" {
  bucket = aws_s3_bucket.backup_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "s3:GetObject",
        Effect    = "Allow",
        Principal = "*",
        Resource  = "${aws_s3_bucket.backup_bucket.arn}/*"
      },
    ]
  })
}