locals {
  name = "${var.project_name}_${var.env}"
  standard_tags = {
    "name"    = local.name
    "creator" = data.aws_caller_identity.current.arn
    "env"     = var.env
  }
  vpc_cidr = var.vpc_cidr

  go_runtime   = "go1.x"
  js16_runtime = "nodejs16.x"
}