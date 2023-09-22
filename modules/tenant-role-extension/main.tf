resource "aws_iam_policy" "custom_policy" {
  name   = "${var.tenant_name}-${var.policy_name}"
  policy = var.iam_policy_json
}

resource "aws_iam_role_policy_attachment" "custom_attach" {
  policy_arn = aws_iam_policy.custom_policy.arn
  role       = "duploservices-${var.tenant_name}"
}
