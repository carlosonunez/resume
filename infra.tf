terraform {
  backend "s3" {}
}

provider "aws" {
  alias = "acm"
  region = "us-east-1"
}

data "aws_route53_zone" "zone" {
  name = "carlosnunez.me."
}

resource "random_string" "bucket" {
  length = 8
  upper = false
  special = false
}

resource "aws_s3_bucket" "resume" {
  bucket = "${random_string.bucket.result}-resume-bucket"
  acl = "private"
}

resource "aws_acm_certificate" "cert" {
  provider = aws.acm
  domain_name = "resume.carlosnunez.me"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  provider = aws.acm
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}


resource "aws_acm_certificate_validation" "cert" {
  provider = aws.acm
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

resource "aws_cloudfront_origin_access_identity" "default" {}

resource "aws_s3_bucket_object" "resume" {
  for_each = {
    "resume.pdf" = "latest.pdf"
    "resume.html" = "index.html" 
    "favicon.ico" = "favicon.ico"
  }
  bucket = aws_s3_bucket.resume.id
  key = each.value
  source = "./output/${each.key}"
  acl = "public-read"
  content_type = each.key == "resume.html" ? "text/html" : "application/pdf"
}

resource "aws_route53_record" "resume" {
  depends_on = [ aws_s3_bucket_object.resume ]
  zone_id = data.aws_route53_zone.zone.id
  name = "resume"
  type = "A"
  alias {
    name = aws_cloudfront_distribution.resume.domain_name
    zone_id = aws_cloudfront_distribution.resume.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_cloudfront_distribution" "resume" {
  origin {
    domain_name = aws_s3_bucket.resume.bucket_regional_domain_name
    origin_id   = "resume_bucket"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases = ["resume.carlosnunez.me"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "resume_bucket"

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

  ordered_cache_behavior {
    path_pattern     = "/latest.pdf"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "resume_bucket"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    minimum_protocol_version = "TLSv1"
    ssl_support_method = "sni-only"
  }
}
