---
external help file: PSRule.Rules.Azure-help.xml
Module Name: PSRule.Rules.Azure
online version: https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/commands/Export-AzRuleTemplateData.md
schema: 2.0.0
---

# Export-AzRuleTemplateData

## SYNOPSIS

Export resource configuration data from Azure templates.

## SYNTAX

### Template (Default)

```text
Export-AzRuleTemplateData [[-Name] <String>] -TemplateFile <String> [-ParameterFile <String[]>]
 [-ResourceGroup <ResourceGroupReference>] [-Subscription <SubscriptionReference>] [-OutputPath <String>]
 [-PassThru] [<CommonParameters>]
```

### Source

```text
Export-AzRuleTemplateData [[-Name] <String>] -SourceFile <String> [-ResourceGroup <ResourceGroupReference>]
 [-Subscription <SubscriptionReference>] [-OutputPath <String>] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION

Export resource configuration data by merging Azure Resource Manager (ARM) template and parameter files.
Template and parameters are merged by resolving template parameters, variables and functions.

This function does not check template files for strict compliance with Azure schemas.

By default this is an offline process, requiring no connectivity to Azure.
Some functions that may be included in templates dynamically query Azure for current state.
For these functions standard placeholder values are used by default.
Functions that use placeholders include `reference`, `list*`.

The `subscription()` function will return the following unless overridden:

- subscriptionId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
- tenantId: 'ffffffff-ffff-ffff-ffff-ffffffffffff'
- displayName: 'PSRule Test Subscription'
- state: 'NotDefined'

The `resourceGroup()` function will return the following unless overridden:

- name: 'ps-rule-test-rg'
- location: 'eastus'
- tags: { }
- properties:
  - provisioningState: 'Succeeded'

To override, set the `AZURE_SUBSCRIPTION` and `AZURE_RESOURCE_GROUP` in configuration.

Currently the following limitations apply:

- Nested templates are expanded, external templates are not.
  - Deployment resources that link to an external template are returned as a resource.
- Sub-resources such as diagnostic logs or configurations are automatically nested.
Automatic nesting a sub-resource requires:
  - The parent resource is defined in the same template.
  - The sub-resource depends on the parent resource.
- The `environment` template function always returns values for Azure public cloud.
- References to Key Vault secrets are not expanded.
A placeholder value is used instead.
- The `reference()` function will return objects for resources within the same template.
  For resources that are not in the same template, a placeholder value is used instead.
- Multi-line strings are not supported.
- Template expressions up to a maximum of 100,000 characters are supported.

## EXAMPLES

### Example 1

```powershell
Export-AzRuleTemplateData -TemplateFile .\template.json -ParameterFile .\parameters.json;
```

Export resource configuration data based on merging a template and parameter file together.

### Example 2

```powershell
Get-AzRuleTemplateLink | Export-AzRuleTemplateData;
```

Recursively scan the current working path and export linked templates.

### Example 3

```powershell
$subscription = @{
  subscriptionId = 'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn'
  displayName = 'My Azure Subscription'
  tenantId = 'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn'
}
Get-AzRuleTemplateLink | Export-AzRuleTemplateData -Subscription $subscription;
```

Export linked templates from the current working path using a specific subscription.

### Example 4

```powershell
$rg = @{
  name = 'my-test-rg'
  location = 'australiaeast'
  tags = @{
    env = 'prod'
  }
}
Get-AzRuleTemplateLink | Export-AzRuleTemplateData -ResourceGroup $rg;
```

Export linked templates from the current working path using a specific resource group.

## PARAMETERS

### -Name

The name of the deployment.
If not specified `export-<xxxxxxxx>` will be used as the name of the deployment.

This parameter is used by the `deployment()` function and is also used to name the output file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemplateFile

The absolute or relative file path to an Azure Resource Manager template file.

```yaml
Type: String
Parameter Sets: Template
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ParameterFile

The absolute or relative file path to one or more Azure Resource Manager template parameter files.

```yaml
Type: String[]
Parameter Sets: Template
Aliases: TemplateParameterFile

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SourceFile

The absolute or relative file path to a file of a Bicep file.

```yaml
Type: String
Parameter Sets: Source
Aliases: f, FullName

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OutputPath

The path to store generated JSON files containing resources.

If this parameter is not specified, output will be written to the current working path.
The file name `resources-<name>.json` will be used when this parameter is not set or a directory is specified.
Where `<name>` is the name of the deployment specified by `-Name`.

This parameter has no affect when `-PassThru` is used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $PWD
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru

By default, FileInfo objects are returned to the pipeline for each JSON file created.
When `-PassThru` is specified, JSON files are not created and Azure resource objects are returned to the pipeline instead.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceGroup

A name or hashtable of the Resource Group where the deployment will occur.
This Resource Group specified here will be used to resolve the `resourceGroup()` function.

When the name of Resource Group is specified, the Resource Group will be looked up and used during export.
This requires an authenticated connection to Azure with permissions to read the specified Resource Group.

Alternately, a hashtable of a Resource Group object can be specified.
This option does not require an authenticated Azure connection.
The hashtable will override the defaults for any specified properties.

For more details see about_PSRule_Azure_Configuration.

```yaml
Type: ResourceGroupReference
Parameter Sets: (All)
Aliases: ResourceGroupName

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Subscription

The name or hashtable of the Subscription where the deployment will occur.
This subscription specified here will be used to resolve the `subscription()` function.

When a subscription name is specified, the Subscription will be looked up and used during export.
This requires an authenticated connection to Azure with permissions to read the specified Subscription.

Alternately, a hashtable of a Subscription object can be specified.
This option does not require an authenticated Azure connection.
The hashtable will override the defaults for any specified properties.

For more details see about_PSRule_Azure_Configuration.

```yaml
Type: SubscriptionReference
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.String[]

## OUTPUTS

### System.IO.FileInfo

### System.Object

## NOTES

## RELATED LINKS
