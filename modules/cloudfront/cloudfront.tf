resource "aws_cloudfront_distribution" "frontend_distribution" {
  origin {
    domain_name = aws_s3_bucket.carioca_front.bucket_regional_domain_name
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend_access_identity.id
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "CariocaFrontendDistribution"
  }
}

resource "aws_cloudfront_origin_access_identity" "frontend_access_identity" {
  comment = "Access Identity for Carioca Frontend"
}
