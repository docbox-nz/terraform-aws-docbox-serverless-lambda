# Terraform AWS Docbox Serverless

This repository contains the `docbox-nz/docbox-serverless-lambda/aws` terraform module. See `examples` for an example usage of this module.

## Provisioned Resources

This module creates and manages the following resources:

- REST API Gateway (Connects your authorizer and exposes the docbox HTTP lambda)
- Storage bucket IAM policies
- Docbox HTTP Lambda
- Docbox Cleanup Lambda (This lambda handles cleaning up of background expired content such as dropped presigned uploads)
    - Cloudwatch event bridge schedule for running the above lambda
- Docbox Upload Completion Lambda
- SQS Queue for upload completion S3 notification
- SQS Queue trigger for the upload completion lambda
- Office Conversion Lambda (This is an external module, see the provided link for the resources this provisions: https://github.com/jacobtread/terraform-aws-office-convert-lambda)
- Docbox Management lambda

There are also associated IAM policies to most of the above resources that are also allocated.
