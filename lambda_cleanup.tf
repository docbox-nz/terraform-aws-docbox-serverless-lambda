locals {
  cleanup_lambda_environment_variables = local.shared_environment_variables
  cleanup_lambda_policies = concat(var.policy_arns, [
    # Provide access to S3 storage for docbox-* buckets
    aws_iam_policy.docbox_s3_access_policy.arn,
  ])

  cleanup_lambda_download_url = "${local.serverless_base_url}/docbox-cleanup-lambda-${local.serverless_zip_arch}.zip"
}

# Lambda for the automated presigned database&s3 cleanup task
module "presigned_cleanup_lambda" {
  source  = "jacobtread/simple-zip-lambda/aws"
  version = "0.2.0"

  architecture           = var.architecture
  function_name          = var.cleanup_lambda_function_name
  zip_source             = var.local_cleanup_lambda_zip_path != null ? var.local_cleanup_lambda_zip_path : local.cleanup_lambda_download_url
  timeout                = var.cleanup_lambda_timeout
  memory_size            = var.cleanup_lambda_memory_size
  environment_variables  = local.cleanup_lambda_environment_variables
  additional_policy_arns = local.cleanup_lambda_policies
}

# Setup a schedule event rule
resource "aws_cloudwatch_event_rule" "cleanup_schedule" {
  name                = "docbox-cleanup-lambda-schedule"
  description         = "Triggers cleanup lambda on a schedule"
  schedule_expression = var.cleanup_schedule_expression
}

# Create the lambda invoke target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.cleanup_schedule.name
  target_id = "SendToLambda"
  arn       = module.presigned_cleanup_lambda.function_arn
}

# Create the invoke permission
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.presigned_cleanup_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cleanup_schedule.arn
}
