# Dedicated CI user for GitHub Actions -- scoped to only this project's
# resources, never given any iam:* permissions on itself or anything else.
resource "aws_iam_user" "ci_deploy" {
  name = "${var.project_name}-ci-deploy"
  tags = local.tags
}

resource "aws_iam_access_key" "ci_deploy" {
  user = aws_iam_user.ci_deploy.name
}

# Deliberately built from variables/locals rather than resource attribute
# references (e.g. site bucket name, not aws_s3_bucket.site.arn) so this
# policy has no dependency on the CloudFront/ACM/S3 resources below. That
# lets it be created in the very first bootstrap apply (Route53 zone + this
# user), before those other resources can safely exist (ACM validation
# needs the zone's nameservers to be live at the registrar first).
data "aws_iam_policy_document" "ci_deploy" {
  # The AWS provider reads back a resource's full state (tags, attached
  # policies, access keys, etc.) on every plan/apply, not just when mutating
  # it -- so the CI user needs read access to its own IAM identity/policy.
  statement {
    sid    = "ManageOwnIamIdentity"
    effect = "Allow"
    actions = [
      "iam:GetUser",
      "iam:ListUserTags",
      "iam:ListAccessKeys",
      "iam:GetAccessKeyLastUsed",
      "iam:ListAttachedUserPolicies",
      "iam:ListUserPolicies",
    ]
    resources = ["arn:aws:iam::${local.account_id}:user/${var.project_name}-ci-deploy"]
  }

  statement {
    sid       = "ManageOwnIamPolicy"
    effect    = "Allow"
    actions   = ["iam:GetPolicy", "iam:GetPolicyVersion", "iam:ListPolicyVersions"]
    resources = ["arn:aws:iam::${local.account_id}:policy/${var.project_name}-ci-deploy"]
  }

  statement {
    sid     = "TerraformStateBucket"
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.project_name}-terraform-state-${local.account_id}-${var.region}",
      "arn:aws:s3:::${var.project_name}-terraform-state-${local.account_id}-${var.region}/*",
    ]
  }

  statement {
    sid       = "TerraformLockTable"
    effect    = "Allow"
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = ["arn:aws:dynamodb:${var.region}:${local.account_id}:table/${var.project_name}-terraform-locks"]
  }

  statement {
    sid    = "Route53ManageOwnZone"
    effect = "Allow"
    actions = [
      "route53:GetHostedZone",
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:GetChange",
      "route53:ListTagsForResource",
    ]
    resources = ["arn:aws:route53:::hostedzone/${aws_route53_zone.main.zone_id}", "arn:aws:route53:::change/*"]
  }

  # No resource-level ARN support in this API.
  statement {
    sid       = "Route53ListZones"
    effect    = "Allow"
    actions   = ["route53:ListHostedZones", "route53:ListHostedZonesByName"]
    resources = ["*"]
  }

  # ACM certificate ARN doesn't exist until requested, and ACM has no
  # useful resource-level conditions for these actions.
  statement {
    sid    = "AcmManageCertificate"
    effect = "Allow"
    actions = [
      "acm:RequestCertificate",
      "acm:DescribeCertificate",
      "acm:GetCertificate",
      "acm:DeleteCertificate",
      "acm:AddTagsToCertificate",
      "acm:RemoveTagsFromCertificate",
      "acm:ListTagsForCertificate",
    ]
    resources = ["*"]
  }

  # CloudFront does not support resource-level permissions for
  # create/list actions on distributions or origin access controls.
  statement {
    sid    = "CloudFrontManageDistribution"
    effect = "Allow"
    actions = [
      "cloudfront:CreateDistribution",
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:UpdateDistribution",
      "cloudfront:DeleteDistribution",
      "cloudfront:TagResource",
      "cloudfront:UntagResource",
      "cloudfront:ListTagsForResource",
      "cloudfront:CreateOriginAccessControl",
      "cloudfront:GetOriginAccessControl",
      "cloudfront:GetOriginAccessControlConfig",
      "cloudfront:UpdateOriginAccessControl",
      "cloudfront:DeleteOriginAccessControl",
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
      "cloudfront:ListInvalidations",
    ]
    resources = ["*"]
  }

  # Full S3 access, but scoped to exactly this one bucket -- covers bucket
  # lifecycle management (create/delete/policy/versioning/encryption/PAB)
  # plus routine object read/write, without enumerating every sub-resource
  # read action the provider's refresh touches (ACL, tagging, CORS, etc.).
  statement {
    sid     = "SiteBucketFullAccess"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${local.site_bucket_name}",
      "arn:aws:s3:::${local.site_bucket_name}/*",
    ]
  }
}

resource "aws_iam_policy" "ci_deploy" {
  name   = "${var.project_name}-ci-deploy"
  policy = data.aws_iam_policy_document.ci_deploy.json
  tags   = local.tags
}

resource "aws_iam_user_policy_attachment" "ci_deploy" {
  user       = aws_iam_user.ci_deploy.name
  policy_arn = aws_iam_policy.ci_deploy.arn
}
