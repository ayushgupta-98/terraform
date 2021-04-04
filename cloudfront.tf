resource "aws_cloudfront_origin_access_identity" "origin-access-identity" {
  comment = "access-identity-${var.PROJECT}-${var.ENVIRONMENT}-s3-bucket.s3.amazonaws.com"
}

resource "aws_cloudfront_distribution" "cf-distribution" {

  lifecycle {
    prevent_destroy = false
    ignore_changes = [default_cache_behavior, aliases, viewer_certificate, custom_error_response, is_ipv6_enabled]
  }
  tags = {
      Name = format("%s-%s",var.PROJECT,var.ENVIRONMENT)
      Project = var.PROJECT
      Environment = var.ENVIRONMENT
  }

  origin {
    domain_name = aws_s3_bucket.s3_bucket.bucket_domain_name
    origin_id = aws_s3_bucket.s3_bucket.bucket
    s3_origin_config {
	    origin_access_identity = aws_cloudfront_origin_access_identity.origin-access-identity.cloudfront_access_identity_path
    }
  }

  enabled = true
  default_root_object = "index.html"
  retain_on_delete = false 

  default_cache_behavior {
    allowed_methods = [ "DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT" ]
    cached_methods = [ "GET", "HEAD" ]
    compress          = true

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
    
    target_origin_id = aws_s3_bucket.s3_bucket.bucket
    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}