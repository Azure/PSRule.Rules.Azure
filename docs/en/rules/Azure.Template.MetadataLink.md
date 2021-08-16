---
severity: Important
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.MetadataLink/
---

# Use parameter file metadata link

## SYNOPSIS

Configure a metadata link for each parameter file.

## DESCRIPTION

A parameter file can include an additional metadata.
This metadata provides additional context for use of the parameter file.

PSRule for Azure uses the `metadata.template` property within parameter files to store a metadata link.
A metadata link, is an explicit association between a parameter file it's intended template file.

This rule is disabled by default but can be enabled by configuring `AZURE_PARAMETER_FILE_METADATA_LINK`.
Enable this rule to ensure that each parameter file has a metadata link to a valid template file.

## RECOMMENDATION

Consider setting metadata for each parameter file linking to the deployment template.

## EXAMPLES

### Configure parameter file

To create parameter files that pass this rule:

- Set the `metadata.template` property to a valid template file path.

For example:

```json
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "templates/storage/v1/template.json"
    },
    "parameters": {
        "storageAccountName": {
            "value": "..."
        }
    }
}
```

## NOTES

Enable this rule by setting the `AZURE_PARAMETER_FILE_METADATA_LINK` option to `true`.

## LINKS

- [Using templates](https://azure.github.io/PSRule.Rules.Azure/using-templates/)
