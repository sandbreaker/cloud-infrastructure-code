
/*
Admin 
*/
resource "aws_iam_group" "admin" {
  name = "${var.env}-admin"
  path = "/admin/"
}

resource "aws_iam_policy" "admin" {
  name = "${var.env}-admin"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "admin" {
  group      = aws_iam_group.admin.id
  policy_arn = aws_iam_policy.admin.arn
}

/*
Service application
*/

resource "aws_iam_user" "service" {
  name = "${var.env}-service"
}

resource "aws_iam_group" "service" {
  name = "${var.env}-service"
  path = "/service/"
}

resource "aws_iam_user_group_membership" "service" {
  user = aws_iam_user.service.name

  groups = [
    aws_iam_group.service.name,
  ]
}

resource "aws_iam_group_policy_attachment" "service" {
  group      = aws_iam_group.service.id
  policy_arn = aws_iam_policy.service.arn
}

resource "aws_iam_policy" "service" {
  name = "${var.env}-service"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": "ec2:Describe*",
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": "elasticloadbalancing:Describe*",
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "cloudwatch:ListMetrics",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:Describe*"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": "autoscaling:Describe*",
        "Resource": "*"
    }
  ]
}
EOF

}


