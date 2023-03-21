variable fis_service_role_arn {
  type = string
}

variable fis_log_group_arn {
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

variable tags {
  type = map(any)
}