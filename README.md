# Powermate Infrastructure

This repository is containing the terraform code for the infrastructure that will be used for this project.

## Pipeline setup

The pipeline will execute the terraform commands automatically as defined in [`.gitlab-ci.yml`](./.gitlab-ci.yml).

Right now we're using 2 different environments `dev` and `prod`.
A push or merge request into the `develop` branch will use the environment specific variables defined in [`terraform/config/dev.tfvars`](./terraform/config/dev.tfvars) while a push or merge request into `main` will use [`terraform/config/prod.tfvars`](./terraform/config/prod.tfvars).
After checking linting (`tflint`) and formatting (`terraform fmt -recursive`) the pipeline will execute first `terraform init` then `terraform validate` and `terraform plan`.
You then can finally trigger the deploy job (`terraform apply`) manually to apply the plan from the last job.

## Local validation of IaC

To avoid the pipeline failing in the first or second step, you can run `terraform init` and `terraform validate` locally first.
This will help to speed up the workflow, as you don't have to rely on the pipeline to see if your terraform code is valid.

To initialize your local terraform to the remote http backend you need to copy the terraform init command which you can do in [powermate-iac > Infrastructure > Terraform](https://gitlab.lrz.de/studi_projects/2023ss_d3i/pc1_umweltinstitut/powermate-iac/-/terraform).
There click on the 3 dot menu next to the terraform state you want to init and select *copy Terraform init command*.
The first line requires a personal access token with API read and write access, which you need to insert. It will look similar to this:
```bash
export GITLAB_ACCESS_TOKEN=<YOUR-ACCESS-TOKEN>
terraform init \
    -backend-config="address=https://gitlab.lrz.de/api/v4/projects/137746/terraform/state/dev_state" \
    -backend-config="lock_address=https://gitlab.lrz.de/api/v4/projects/137746/terraform/state/dev_state/lock" \
    -backend-config="unlock_address=https://gitlab.lrz.de/api/v4/projects/137746/terraform/state/dev_state/lock" \
    -backend-config="username=<YOUR-USERNAME>" \
    -backend-config="password=$GITLAB_ACCESS_TOKEN" \
    -backend-config="lock_method=POST" \
    -backend-config="unlock_method=DELETE" \
    -backend-config="retry_wait_min=5"
```
After executing the copied terraform init command you can check if your terraform code is valid using `terraform validate`.
Also, please make sure to run `terraform fmt -recursive` before you push changes, or configure your IDE to do so on save.

## Infrastructure code structure

The code is managed in multiple terraform modules to reuse terraform code for e.g. different environments.
It's very important to have the infrastructure code well organized to keep a good overview over the deployed infrastructure.
If there are policies to be used to grant access to the module's resources, 
we want to have only the attachment resource outside the module next to the resources that the access is granted to via policy attachment.
The policies and the roles that the polices are to be attached to are exported from the module via its outputs.

```hcl
# modules/timestream/main.tf
resource "aws_iam_policy" "for_data_api_lambda" {
  name        = "data_api_lambda_timestream_access"
  description = "IAM policy to be used to grant api lambda READ access to timestream db '${aws_timestreamwrite_database.main.database_name}'"
  policy      = data.aws_iam_policy_document.for_data_api_lambda.json
  tags        = var.tags
}

resource "aws_iam_policy" "for_ingress_endpoint" {
  name        = "lambda_ingress_endpoint_timestream_access"
  description = "IAM policy to be used to grant ingress endpoint lambda WRITE access to timestream db '${aws_timestreamwrite_database.main.database_name}'"
  policy      = data.aws_iam_policy_document.for_ingress_endpoint.json
  tags        = var.tags
}

# modules/timestream/output.tf
output "policies" {
  description = "ARN's of the created policies to be used to access this timestream db"
  value       = {
    for_ingress_lambda  = aws_iam_policy.for_ingress_endpoint.arn
    for_data_api_lambda = aws_iam_policy.for_data_api_lambda.arn
  }
}

# ingress_endpoint_sqs.tf
resource "aws_iam_role_policy_attachment" "lambda_timestream_policy" {
  policy_arn = module.timestream_db.policies.for_ingress_lambda
  role       = module.ingress_endpoint_lambda.iam_role_name
}

# api.tf
resource "aws_iam_role_policy_attachment" "data_api_lambda_timestream" {
  policy_arn = module.timestream_db.policies.for_data_api_lambda
  role       = module.api_lambda_data.iam_role_name
}
```

Every module lives in [`terraform/modules`](./terraform/modules/) and is to be used from the files living in the [`terraform`](./terraform/) folder, which serves as the root folder for terraform.

| file                                                                       | purpose                                                                                                                                                                                                                                                                                                                                                                                                              |
|----------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`terraform/provider.tf`](./terraform/provider.tf)                         | terraform's provider configuration                                                                                                                                                                                                                                                                                                                                                                                   |
| [`terraform/data.tf`](./terraform/data.tf)                                 | all hcl `data` objects                                                                                                                                                                                                                                                                                                                                                                                               |
| [`terraform/output.tf`](./terraform/output.tf)                             | all hcl `output` objects                                                                                                                                                                                                                                                                                                                                                                                             |
| [`terraform/variables.tf`](./terraform/variables.tf)                       | all hcl `variable` objects that are to be injected by the pipeline                                                                                                                                                                                                                                                                                                                                                   |
| [`terraform/network.tf`](./terraform/network.tf)                           | all the network infrastrucutre (VPC's, subnets, ...)                                                                                                                                                                                                                                                                                                                                                                 |
| [`terraform/api.tf`](./terraform/api.tf)                                   | infrastructure code for the API to be used by [`powermate-app`](https://gitlab.lrz.de/studi_projects/2023ss_d3i/pc1_umweltinstitut/powermate-app). Note that the lambda's code is located at repository [`lambdas/powermate-api-monorepo`](https://gitlab.lrz.de/studi_projects/2023ss_d3i/pc1_umweltinstitut/lambdas/powermate-api-monorepo). The pipeline of that repository will update the lambda's source code. |
| [`terraform/ingress_endpoint_sqs.tf`](./terraform/ingress_endpoint_sqs.tf) | infrastructure for the data ingress endpoint that receives the data from IOT. (IoT Core -> SQS -> Lambda).  Note that the lambda's code is located at repository [`lambdas/powermate-ingress-endpoint-lambda`](https://gitlab.lrz.de/studi_projects/2023ss_d3i/pc1_umweltinstitut/lambdas/powermate-ingress-endpoint-lambda). The pipeline of that repository will update the lambda's source code.                  |
| [`terraform/authz.tf`](./terraform/authz.tf)                               | infrastructure of the authorizer lambda which is responsible for authorizing requests to the API.                                                                                                                                                                                                                                                                                                                    |
| [`terraform/cognito.tf`](./terraform/cognito.tf)                           | infrastructure of the AWS cognito setup. Cognito serves as identity provider / authenticator in our setup.                                                                                                                                                                                                                                                                                                           |
| [`terraform/timestream.tf`](./terraform/timestream.tf)                     | the AWS timestream DB which is our main database for storing magnet field and rotation data                                                                                                                                                                                                                                                                                                                          |
| [`terraform/iot_core_policies.tf`](./terraform/iot_core_policies.tf)       | contains all the necessary policies that are needed by the provisioning API lambda and devices API lambda                                                                                                                                                                                                                                                                                                            |