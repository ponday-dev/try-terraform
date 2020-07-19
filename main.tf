variable "access_key" {}
variable "secret_key" {}
variable "region" { default = "ap-northeast-1" }
variable "bucket_name" {}

provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region = var.region
}

resource "aws_cloudfront_origin_access_identity" "oai" {
    comment = var.bucket_name
}

data "template_file" "s3_policy" {
    template = file("s3/policy.json.tpl")

    vars = {
        bucket_name = var.bucket_name
        origin_access_identity = aws_cloudfront_origin_access_identity.oai.id
    }
}

resource "aws_s3_bucket" "public" {
    bucket = var.bucket_name
    acl = "public-read"
    force_destroy = true
    policy = data.template_file.s3_policy.rendered

    website {
        index_document = "index.html"
    }
}

resource "aws_cloudfront_distribution" "cf" {
    enabled = true
    default_root_object = "index.html"
    retain_on_delete = true

    origin {
        domain_name = aws_s3_bucket.public.bucket_regional_domain_name
        origin_id = aws_s3_bucket.public.id

        s3_origin_config {
            origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
        }
    }

    default_cache_behavior {
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = aws_s3_bucket.public.id

        forwarded_values {
            query_string = false

            cookies {
                forward = "none"
            }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl = 0
        default_ttl = 300
        max_ttl = 86400
    }

    restrictions {
        geo_restriction {
            restriction_type = "whitelist"
            locations = ["US", "CA", "GB", "DE", "JP"]
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }
}

resource "aws_s3_bucket_object" "index" {
    bucket = aws_s3_bucket.public.id
    key = "index.html"
    source = "s3/index.html"
    content_type = "text/html"
    etag = filemd5("s3/index.html")
}

output "s3_website_endpoint" { value = aws_s3_bucket.public.website_endpoint }
output "cloudfront_domain_name" { value = aws_cloudfront_distribution.cf.domain_name }
