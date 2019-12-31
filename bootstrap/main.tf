resource "aws_s3_bucket" "default" {
  bucket = var.name
  acl    = "private"
  region = "us-east-1"

  tags = {
    Name        = "AWS Socket Chat Application"
    Environment = "Production"
    Description = "Storage of the cloudformation templates."
  }
}


resource "aws_s3_bucket_public_access_block" "block" {
  bucket = "${aws_s3_bucket.default.id}"

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
}

variable "name" {
  type = string
}

output "cloudformation_bucket" {
  value = aws_s3_bucket.default.id
}
