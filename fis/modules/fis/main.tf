resource "aws_fis_experiment_template" "kill_pod" {
  description = "Kill Pod app-ags"
  role_arn    = var.fis_service_role_arn

  stop_condition {
    source = "none"
  }

  action {
    name      = "KillPodAction"
    action_id = "aws:eks:inject-kubernetes-custom-resource"

    parameter {
      key = "kubernetesApiVersion"
      value = "chaos-mesh.org/v1alpha1"
    }

    parameter {
      key = "kubernetesKind"
      value = "PodChaos"
    }

    parameter {
      key = "kubernetesNamespace"
      value = "vodd-int"
    }

    parameter {
      key = "kubernetesSpec"
      value = jsonencode({
        "selector":{
          "namespaces":["vodd-int"],
          "labelSelectors":{"app":"app-ags"}
          },
        "mode":"one",
        "action":"pod-kill"
        })
    }

    # Eks is not supported
    # https://github.com/hashicorp/terraform-provider-aws/pull/27337
    target {
      key   = "Clusters" # [Clusters DBInstances Instances SpotInstances Nodegroups Roles]
      value = "KillPodTarget"
    }
  }

  target {
    name           = "KillPodTarget"
    resource_type  = "aws:eks:cluster"
    selection_mode = "COUNT(1)"
    resource_arns = [var.eks_arn]
  }
}

resource "aws_fis_experiment_template" "cpu_stress_pod" {
  description = "CPU Stress Pod app-aus"
  role_arn    = var.fis_service_role_arn

  stop_condition {
    source = "none"
  }

  action {
    name      = "CPUStressPodAction"
    action_id = "aws:eks:inject-kubernetes-custom-resource"

    parameter {
      key = "kubernetesApiVersion"
      value = "chaos-mesh.org/v1alpha1"
    }

    parameter {
      key = "kubernetesKind"
      value = "StressChaos"
    }

    parameter {
      key = "kubernetesNamespace"
      value = "vodd-int"
    }

    parameter {
      key = "kubernetesSpec"
      value = jsonencode({
        "selector":{
          "namespaces":["vodd-int"],
          "labelSelectors":{"app":"app-aus"}
          },
          "mode":"one",
          "stressors": {
            "cpu":{
              "workers":1,
              "load":50
            }
          },
          "duration":"1m"
        })
    }

    parameter {
      key = "maxDuration"
      value = "PT1M"
    }

    target {
      key   = "Clusters"
      value = "CPUStressPodTarget"
    }
  }

  target {
    name           = "CPUStressPodTarget"
    resource_type  = "aws:eks:cluster"
    selection_mode = "COUNT(1)"
    resource_arns = [var.eks_arn]
  }
}

resource "aws_fis_experiment_template" "terminate_ec2" {
  description = "Terminate EC2 in a Nodegroup"
  role_arn    = var.fis_service_role_arn

  stop_condition {
    source = "none"
  }

  action {
    name      = "TerminateEC2Action"
    action_id = "aws:eks:terminate-nodegroup-instances"

    parameter {
      key = "instanceTerminationPercentage"
      value = "50"
    }

    target {
      key   = "Nodegroups"
      value = "TerminateEC2Target"
    }
  }

  target {
    name           = "TerminateEC2Target"
    resource_type  = "aws:eks:nodegroup"
    selection_mode = "COUNT(1)"
    resource_arns = [var.nodegroup_arn]
  }
}

resource "aws_fis_experiment_template" "reboot_rds" {
  description = "Reboot RDS"
  role_arn    = var.fis_service_role_arn

  stop_condition {
    source = "none"
  }

  action {
    name      = "RebootRDSAction"
    action_id = "aws:rds:reboot-db-instances"

    parameter {
      key = "forceFailover"
      value = true
    }

    target {
      key   = "DBInstances"
      value = "RebootRDSTarget"
    }
  }

  target {
    name           = "RebootRDSTarget"
    resource_type  = "aws:rds:db"
    selection_mode = "COUNT(1)"

    resource_arns = [var.rds_arn]
  }
}