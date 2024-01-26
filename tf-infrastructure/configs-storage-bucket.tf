/*
  THIS IS INSECURE AND BAD PRACTICES 
  TODO: FIX 
*/
resource "aws_s3_bucket" "configs-storage-bucket" {
  bucket = "ccdc24testenvconfigfiles"
}

resource "aws_s3_bucket_ownership_controls" "configs-storage-bucket" {
  bucket = aws_s3_bucket.configs-storage-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "configs-storage-bucket" {
  bucket = aws_s3_bucket.configs-storage-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "configs-storage-bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.configs-storage-bucket,
    aws_s3_bucket_public_access_block.configs-storage-bucket,
  ]

  bucket = aws_s3_bucket.configs-storage-bucket.id
  acl    = "public-read-write"
}

/*
TO UPLOAD A RESOURCE WITHIN TERRAFORM (EXAMPLE): 
resource "local_file" "example-upload" {
  content = <<-DOC
    Hello World
    DOC
  filename = "${path.module}/hello-world.txt"
}

resource "aws_s3_object" "configs-storage-bucket" {
  bucket = aws_s3_bucket.configs-storage-bucket.id
  key    = "hello-world.txt"
  source = local_file.example-upload.filename
}
*/
