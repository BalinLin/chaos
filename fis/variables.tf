variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI profile"
}

variable stack_name {
  type = string
}

variable eks_arn {
  type = string
}

variable nodegroup_arn {
  type = string
}

variable rds_arn {
  type = string
}