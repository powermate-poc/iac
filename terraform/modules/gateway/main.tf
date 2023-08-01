resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.project_name}_api_gateway"
  description = "AWS API Gateway proxying AWS Lambdas"
  tags        = var.tags

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  body = data.template_file.open_api_spec.rendered
}

data "template_file" "open_api_spec" {
  template = var.api_template

  vars = var.api_template_vars
}