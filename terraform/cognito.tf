resource "aws_cognito_user_pool" "end_users" {
  name                     = "${local.name}_end_users_pool"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
  # We allow the public to create user profiles

  verification_message_template {
    default_email_option  = "CONFIRM_WITH_LINK"
    email_subject_by_link = "${replace(local.name, "_", " ")} | Account Verification"
    email_message_by_link = <<EOF
    Dear User,

    Thank you for choosing PowerMate! We're thrilled to have you join our community.
    Before you can start exploring the exciting features of PowerMate, we need to verify your account.
    This step ensures the security of your information and helps us maintain a safe environment for all users.


    To complete the verification process, verify your PowerMate account by clicking on the following link:

    {##Click Here##}


    If you didn't request this account creation or believe this email was sent to you by mistake, please disregard it.
    Your account will not be activated unless you complete the verification process.
    We value your privacy and assure you that your personal information is protected in accordance with our privacy policy.
    Welcome to PowerMate! We're excited to have you on board and look forward to providing you with a seamless experience.

    Best regards,

    The PowerMate Team
    EOF
  }
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  schema {
    attribute_data_type = "String"
    name                = "email"
    mutable             = false
    required            = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
  mfa_configuration = "OFF"
}

resource "aws_cognito_user_pool_client" "frontend" {
  name                                 = "${local.name}_frontend_client"
  explicit_auth_flows                  = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  user_pool_id                         = aws_cognito_user_pool.end_users.id
  callback_urls                        = [aws_api_gateway_deployment.this.invoke_url]
  default_redirect_uri                 = aws_api_gateway_deployment.this.invoke_url
  allowed_oauth_flows_user_pool_client = true
  read_attributes                      = ["email", "email_verified", "preferred_username"]
  allowed_oauth_flows                  = ["implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  generate_secret                      = false
  supported_identity_providers         = ["COGNITO"]
  id_token_validity                    = 24

}

resource "aws_cognito_user_pool_domain" "end_users" {
  domain       = "${var.project_name}-${var.env}"
  user_pool_id = aws_cognito_user_pool.end_users.id
}
