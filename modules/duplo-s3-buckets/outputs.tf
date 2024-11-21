# output "shared_s3_bucket_names" {
#   value = { for k, b in duplocloud_s3_bucket.shared : k => b.fullname }
# }

# output "sandbox_s3_bucket_names" {
#   value = { for k, b in duplocloud_s3_bucket.sandbox: k => b.fullname }
# }

# output "live_s3_bucket_names" {
#   value = { for k, b in duplocloud_s3_bucket.live: k => b.fullname }
# }

output "s3_bucket_details" {
  value = {
    for k, b in duplocloud_s3_bucket.bucket : k => {
      domain_name = b.domain_name
      id          = b.id
      fullname    = b.fullname
      arn         = b.arn
    }
  }
}
