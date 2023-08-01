resource "aws_iam_role" "iot_role" {
  name               = "${var.project_name}_iot_role"
  assume_role_policy = data.aws_iam_policy_document.iot_assume_role.json
  tags               = var.tags
}