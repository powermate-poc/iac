locals {
  policy_prefix = "${local.name}_iot_core"
}


###################################################################
####### devices endpoint##############################################
###################################################################
resource "aws_iam_policy" "for_devices_api_lambda" {
  name   = "${local.policy_prefix}_devices_endpoint_permissions"
  policy = data.aws_iam_policy_document.for_devices_api_lambda.json
}

data "aws_iam_policy_document" "for_devices_api_lambda" {
  version = "2012-10-17"
  statement {
    sid       = "AllowListThings"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "iot:ListThings"
    ]
  }
}

###################################################################
####### provisioning endpoint #####################################
###################################################################
resource "aws_iam_policy" "for_provisioning_api_lambda" {
  name   = "${local.policy_prefix}_provisioning_endpoint_permissions"
  policy = data.aws_iam_policy_document.for_provisioning_api_lambda.json

}

data "aws_iam_policy_document" "for_provisioning_api_lambda" {
  version = "2012-10-17"
  statement {
    sid       = "AllowThingCreation"
    effect    = "Allow"
    resources = ["arn:aws:iot:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:thing*"]
    actions = [
      "iot:DescribeThing", "iot:CreateThing"
    ]
  }

  statement {
    sid       = "AllowCertificateCreation"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "iot:CreateKeysAndCertificate",
      "iot:AttachThingPrincipal"
    ]
  }

  statement {
    sid       = "AllowCertificateAttachments"
    effect    = "Allow"
    resources = ["arn:aws:iot:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:cert*"]
    actions = [
      "iot:AttachPolicy",
    ]
  }

  statement {
    sid       = "AllowThingDeletion"
    effect    = "Allow"
    resources = ["arn:aws:iot:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:thing*"]
    actions = [
      "iot:DeleteThing"
    ]
  }

  statement {
    sid       = "AllowCertificateDeletion"
    effect    = "Allow"
    resources = ["arn:aws:iot:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:cert*"]
    actions = [
      "iot:DeleteCertificate", "iot:DetachPolicy", "iot:UpdateCertificate",
    ]
  }

  statement {
    sid       = "AllowPrincipalDetachment"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "iot:ListThingPrincipals", "iot:DetachThingPrincipal"
    ]
  }
}

###################################################################
####### thing policy ##############################################
###################################################################
resource "aws_iot_policy" "for_thing_pub_clientId" {
  name = "${local.name}_thing_pub_client_id"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iot:Publish",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:topic/$${iot:Connection.Thing.ThingName}/*"
      },
      {
        Action = [
          "iot:Connect",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:client/$${iot:Connection.Thing.ThingName}"
      },
    ]
  })
}
