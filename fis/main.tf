terraform {
  backend s3 {} # Should be manually created before running this code
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.38.0"
    }
  }
}

locals {
  tags = {
    Terraform = "true"
    Stack     = var.stack_name
    Region    = var.aws_region
  }
}

module "iam" {
  source                      = "./modules/iam"
  tags                        = local.tags
}

module "cw" {
  source                      = "./modules/cw"
  tags                        = local.tags
}

module "fis" {
  source                      = "./modules/fis"
  fis_service_role_arn        = module.iam.fis_service_role_arn
  fis_log_group_arn           = module.cw.fis_log_group_arn
  eks_arn                     = var.eks_arn
  nodegroup_arn               = var.nodegroup_arn
  rds_arn                     = var.rds_arn
  tags                        = local.tags
  depends_on                  = [module.iam, module.cw]
}
