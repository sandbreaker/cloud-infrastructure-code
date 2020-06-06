/*
S3 buckets
*/

resource "aws_s3_bucket" "s3_log" {
  bucket = "${var.env}-${var.corp}-log"
  acl    = "private"

  tags = {
    Name        = "General Logging"
    Environment = var.env
  }
}

resource "aws_s3_bucket" "s3_data" {
  bucket = "${var.env}-${var.corp}-data"
  acl    = "private"

  tags = {
    Name        = "Data Lake"
    Environment = var.env
  }
}

resource "aws_s3_bucket" "s3_static_config" {
  bucket = "${var.env}-${var.corp}-sconfig"
  acl    = "private"

  tags = {
    Name        = "Static configuration"
    Environment = var.env
  }
}

resource "aws_s3_bucket" "s3_dynamic_config" {
  bucket = "${var.env}-${var.corp}-dconfig"
  acl    = "private"

  tags = {
    Name        = "Dynamic configuration"
    Environment = var.env
  }
}

resource "aws_s3_bucket" "s3_lambda" {
  bucket = "${var.env}-${var.corp}-lambda"
  acl    = "private"

  tags = {
    Name        = "Lamba Packages"
    Environment = var.env
  }
}

/*
Policies for s3 access
*/
data "aws_iam_policy_document" "s3_policy_service" {
  statement {
    sid = ""

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.s3_log.arn,
      aws_s3_bucket.s3_data.arn,
      aws_s3_bucket.s3_dynamic_config.arn,
      aws_s3_bucket.s3_static_config.arn,
      aws_s3_bucket.s3_lambda.arn,

    ]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "s3_policy_service" {
  name   = "${var.env}-s3-policy-service"
  policy = data.aws_iam_policy_document.s3_policy_service.json
}

// use the service group to attach the s3 bucket policies
resource "aws_iam_group_policy_attachment" "s3_policy_service" {
  group      = aws_iam_group.service.arn
  policy_arn = aws_iam_policy.s3_policy_service.arn
}
