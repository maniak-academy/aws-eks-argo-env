resource "aws_s3_bucket" "backup_bucket" {
  bucket = "sebbycorp-mongodb-backups3" # Ensure this is globally unique

  # Prevent accidental bucket destruction
  lifecycle {
    prevent_destroy = true
  }

  # Optionally, include tags directly here if not using a variable
  tags = merge(
    var.tags
  )
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.backup_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}