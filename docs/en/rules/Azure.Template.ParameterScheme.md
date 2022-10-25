---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.ParameterScheme/
---

# Use a https template parameter file schema

## SYNOPSIS

Use an Azure template parameter file schema with the https scheme.

## DESCRIPTION

JSON schemas are used to validate the structure of Azure template parameter files.
The JSON schema specification permits schemas to use https or http schemes.
When using referencing schemas served by `schema.management.azure.com` the http scheme redirects to https.

While `http://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#` points to a file.
All supported Azure template parameter schemas use the https scheme.

## RECOMMENDATION

Consider using a schema with the https scheme.

## EXAMPLES

### Configure with Azure template

To define Azure template parameter files that pass this rule:

- Configure the template parameter schema to a supported schema with the `https://` URI prefix,
  such as `https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#`.

For example:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": { }
}
```

## LINKS

- [Automate deployments with ARM Templates](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure#automate-deployments-with-arm-templates)
- [Test cases for parameter files](https://docs.microsoft.com/azure/azure-resource-manager/templates/parameter-file-test-cases)
- [Create Resource Manager parameter file](https://docs.microsoft.com/azure/azure-resource-manager/templates/parameter-files)
