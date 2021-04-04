resource "aws_s3_bucket" "s3_bucket" {
  bucket = format("%s-%s-%s",var.PROJECT,var.ENVIRONMENT,"s3-bucket")
  tags = {
      Name = format("%s-%s-%s",var.PROJECT,var.ENVIRONMENT,"s3-bucket")
      Project = var.PROJECT
      Environment = var.ENVIRONMENT
  }
  server_side_encryption_configuration {
		rule {
			apply_server_side_encryption_by_default {
				sse_algorithm     = "AES256"
			}
		}
	}
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = jsonencode({
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.origin-access-identity.id}"
            },
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.s3_bucket.arn}/*"
        }
    ]
  })
}