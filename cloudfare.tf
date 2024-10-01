terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.16.0" # Specify the desired version
    }
  }
}
provider "cloudflare" {
  email   = "Vishnuarunwrk@gmai.com"
  api_key = "2a05ec6fbdfa5c887ac136f42df1d1355c510"
}

resource "cloudflare_record" "cdn" {
  zone_id = "26ca592fbb81954506dfc428cf0d1daf"
  name    = "www"
  value   = aws_cloudfront_distribution.cdn.domain_name
  type    = "CNAME"
  ttl     = 3600
}
