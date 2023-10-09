---
reviewed: 2023-10-06
severity: Critical
pillar: Cost Optimization
category: Provision
resource: ML
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ML.ComputeIdleShutdown/
---

# Name of rule

## SYNOPSIS

Use ML - Compute Instances configured for idle shutdown.

## DESCRIPTION

Machine Learning uses compute instances as a training or inference compute for development and testing. It's similar to a virtual machine on the cloud.

To avoid getting charged for a compute instance that is switched on but not being actively used, you can configure when to automatically shut down compute instances due to inactivity.


## RECOMMENDATION

Consider configuring ML - Compute Instances to automatically shutdown after a period of idle use as part of a broader cost optimization strategy. 

## EXAMPLES

### Configure with Azure template

To deploy resource that pass this rule:

- steps

For example:

```json

```

### Configure with Bicep

To deploy resource that pass this rule:

- steps

For example:

```bicep

```

## LINKS

- [Configure idle shutdown](https://learn.microsoft.com/azure/machine-learning/how-to-create-compute-instance?view=azureml-api-2&tabs=azure-cli#configure-idle-shutdown)
- [ML - Compute objects](https://learn.microsoft.com/azure/templates/microsoft.machinelearningservices/workspaces/computes?pivots=deployment-language-bicep#compute-objects)
- [ML Compute](https://learn.microsoft.com/azure/machine-learning/azure-machine-learning-glossary?view=azureml-api-2#compute)
- [AI + Machine Learning cost estimates](https://learn.microsoft.com/azure/well-architected/cost/provision-ai-ml)
