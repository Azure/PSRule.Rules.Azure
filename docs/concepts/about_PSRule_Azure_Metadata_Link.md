# PSRule_Azure_Metadata_Link

## about_PSRule_Azure_Metadata_Link

## SHORT DESCRIPTION

Describes how Azure Resource Manager (ARM) parameter files reference a template file.

## LONG DESCRIPTION

Azure Resource Manager (ARM) supports storing additional metadata within parameter files.
PSRule uses this metadata to link template and parameter files together to improve unit testing of templates.

To reference a template within a parameter file:

- Set the `metadata.template` property to the template.
- Prefix a template file relative to the parameter file with `./`.
When `./` is not used, the template with is relative to the `-Path` parameter.

For example:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "./Resources.Template.json"
    },
    "parameters": {
    }
}
```

## NOTE

An online version of this document is available at https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/concepts/about_PSRule_Azure_Metadata_Link.md.

## SEE ALSO

- [Get-AzRuleTemplateLink](https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/commands/Get-AzRuleTemplateLink.md)

## KEYWORDS

- Link
- Template
