output "route53_name_servers" {
  description = "Set these as the nameservers for the domain at Spaceship (or whichever registrar it's on)."
  value       = aws_route53_zone.main.name_servers
}

output "cloudfront_distribution_id" {
  description = "Used by the deploy-site workflow to invalidate the CDN cache after each deploy."
  value       = aws_cloudfront_distribution.site.id
}

output "site_bucket_name" {
  description = "S3 bucket the deploy-site workflow syncs the built site into."
  value       = aws_s3_bucket.site.id
}

output "ci_deploy_access_key_id" {
  description = "Set as the AWS_ACCESS_KEY_ID GitHub Actions secret."
  value       = aws_iam_access_key.ci_deploy.id
}

output "ci_deploy_secret_access_key" {
  description = "Set as the AWS_SECRET_ACCESS_KEY GitHub Actions secret."
  value       = aws_iam_access_key.ci_deploy.secret
  sensitive   = true
}
