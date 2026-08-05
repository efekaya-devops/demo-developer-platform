# requested through the portal, don't hand-edit - raise a new request instead
module "${{ values.bucketName }}" {
  source = "git::https://github.com/efekaya-devops/terraform-modules.git//modules/aws-s3?ref=main"

  name       = "${{ values.bucketName }}"
  versioning = ${{ values.versioning }}

  tags = {
    Team        = "${{ values.team }}"
    Environment = "${{ values.environment }}"
    ManagedBy   = "terraform"
  }
}
