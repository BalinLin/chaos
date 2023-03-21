`terraform: v1.3.6` `aws provider: v4.55.0`

<!-- TOC -->

- [About the project.](#about-the-project)
- [Cloudformation](#cloudformation)
- [AWS CLI](#aws-cli)
- [Terraform](#terraform)
- [Issues](#issues)
- [Error state on AWS FIS experiment](#error-state-on-aws-fis-experiment)
- [Reference](#reference)

<!-- /TOC -->

# About the project.
- Use different API to create FIS templates for chaos engineering.

# Cloudformation
- Upload the `./cf/cf.yaml` file to AWS Cloudformation console.

# AWS CLI
- Fill
```bash
aws fis --profile {{ profile }} --region {{ aws_region }} create-experiment-template --cli-input-json file://cli/StressChaos.json
```

# Terraform
- Shell command to run this project
```bash
# init
zsh run.sh init

# show change and plan file
zsh run.sh plan

# apply with .plan
zsh run.sh apply

# destroy
zsh run.sh destroy
```

# Issues
Unknown parameter in input: "logConfiguration", must be one of: clientToken, description, stopConditions, targets, actions, roleArn, tags.
- [aws fis create-experiment-template support logConfiguration after version 2.4.22](https://raw.githubusercontent.com/aws/aws-cli/v2/CHANGELOG.rst), NI is using AWS CLI v2.2.8.
- [We might need to upgrade AWS CLI to 2.5.8 or higher](https://github.com/Young-ook/terraform-aws-fis#known-issues)

Terraform AWS provider do not support resource of type EKS Cluster. You can use AWS CLI or Cloudformation instead.
- [[Bug]: aws_fis_experiment_template should support resource of type EKS Cluster #27314](https://github.com/hashicorp/terraform-provider-aws/issues/27314)
- [Added FIS support for EKS Cluster #27337](https://github.com/hashicorp/terraform-provider-aws/pull/27337)

# Error state on AWS FIS experiment
**Unable to get custom resource: Unexpected status.**
> AWS FIS can't find the third party chaos tool.
- You need to install chaos-mesh in the cluster.

**Action exceeded the specified maximum duration.**
> AWS FIS cant't find the corresponding resources you specify in the experiment.
- Check the target arns, tags, etc.
> The execution time is more then the `maxDuration` you specify in the experiment.
- Reduce the `duration` in the field `kubernetesSpec` if the action type is `aws:eks:inject-kubernetes-custom-resource`.
- It need a few second for the third party chaos tool to deploy the service and inject the chaos. It will be failed if the `duration` is equal or more than the `maxDuration` you specify in the experiment.

**Unable to inject custom resource: Kubernetes API returned status code 422. Please check EKS logs for more details.**
> The JSON data in the field `kubernetesSpec` is insufficient if the action type is `aws:eks:inject-kubernetes-custom-resource`.
- Check the JSON format and the the required fields.

**Unable to inject custom resource: Not authorized to perform the required action.**
> Action type `aws:eks:inject-kubernetes-custom-resource` need rbac permission in your cluster.
- You need to setup the IAM Role the configmap `aws-auth` in the namespace `kube-system`
- You can also use the following command to modify the setting manually.
```bash
# Use the command in your EKS Cluster
kubectl edit -n kube-system configmap/aws-auth
```

# Reference
- [AWS FIS actions reference](https://docs.aws.amazon.com/fis/latest/userguide/fis-actions-reference.html)
- [aws_fis_experiment_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fis_experiment_template)
- [aws_fis_experiment_template github](https://github.com/hashicorp/terraform-provider-aws/blob/549d30c277cec0cedbf176a2d01879d646d6a413/website/docs/r/fis_experiment_template.html.markdown)
- [AWS Failure Injection Simulator (FIS) experiment template resource #18125](https://github.com/hashicorp/terraform-provider-aws/issues/18125)