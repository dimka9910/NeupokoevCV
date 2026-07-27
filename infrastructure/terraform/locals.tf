locals {
  tags = merge(
    {
      Project   = var.project_name
      ManagedBy = "terraform"
    },
    var.extra_tags
  )

  account_id       = data.aws_caller_identity.current.account_id
  site_bucket_name = "${var.project_name}-site-${local.account_id}"
}
