
output "aws_iam_group_admin" {
  value = aws_iam_group.admin.id
}

output "aws_iam_group_service" {
  value = aws_iam_group.service.id
}

output "aws_iam_policy_cloudwatch_arn" {
  value = aws_iam_policy.cloudwatch.arn
}
