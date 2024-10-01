provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAZI2LCETGE75CR445"
  secret_key = "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"
}

# Reference to the existing S3 bucket
variable "static-webb-hosting" {
  description = "static-webb-hosting"
  type        = string
}

# Use the existing S3 bucket
resource "aws_s3_bucket_object" "website_assets" {
  bucket = var.existing_bucket_name  # Use the existing bucket name
  key    = "index.html"
  source = "https://static-webb-hosting.s3.amazonaws.com/index.html"  # Update this path to where your index.html is located
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "static_website_policy" {
  bucket = var.existing_bucket_name  # Use the existing bucket name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS": "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${var.existing_bucket_name}/*"
      }
    ]
  })
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Access Identity for S3 Bucket"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = "${var.existing_bucket_name}.s3.amazonaws.com"  # Reference the existing S3 bucket
    origin_id   = "S3-${var.existing_bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.existing_bucket_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
