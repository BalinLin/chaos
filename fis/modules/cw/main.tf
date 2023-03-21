resource "aws_cloudwatch_log_group" "fis_log_group" {
  name              = "/aws/fis/nsi-eks-int-22"
  skip_destroy      = false
  retention_in_days = 30
}