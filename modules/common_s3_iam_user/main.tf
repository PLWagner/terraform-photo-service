resource "aws_iam_user" "bucket_user" {
  name = "${var.s3_bucket_name}_user"
  tags = var.tags
}

resource "aws_iam_access_key" "bucket_user_key" {
  user    = aws_iam_user.bucket_user.name
  pgp_key = var.s3_iam_access_key_pgp
}

data "aws_iam_policy_document" "bucket_user_policy" {
  statement {
    actions = var.s3_policy_actions

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }

  dynamic "statement" {
    for_each = (var.cf_cloudfront_distribution_arn == "" ? [] : [var.cf_cloudfront_distribution_arn])

    content {
      actions = var.cf_policy_actions

      resources = [
        "${var.cf_cloudfront_distribution_arn}",
      ]
    }
  }
}

resource "aws_iam_policy" "bucket_user_policy" {
  name   = "${var.s3_bucket_name}_policy"
  policy = data.aws_iam_policy_document.bucket_user_policy.json
  tags   = var.tags
}

resource "aws_iam_user_policy_attachment" "bucket_user_policy_attachment" {
  policy_arn = aws_iam_policy.bucket_user_policy.arn
  user       = aws_iam_user.bucket_user.name
}

resource "aws_iam_policy" "ses_policy" {
  count = var.ses_policy_enabled ? 1 : 0

  name  = "${var.s3_bucket_name}_ses_policy"
  policy = var.ses_policy
  tags   = var.tags
}

resource "aws_iam_user_policy_attachment" "ses_policy_attachment" {
  count = var.ses_policy_enabled ? 1 : 0

  policy_arn = aws_iam_policy.ses_policy[0].arn
  user       = aws_iam_user.bucket_user.name
}
