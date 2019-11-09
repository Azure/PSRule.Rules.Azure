---
external help file: PSRule.Rules.Azure-help.xml
Module Name: PSRule.Rules.Azure
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/commands/PSRule.Rules.Azure/en-US/Export-AzTemplateRuleData.md
schema: 2.0.0
---

# Export-AzTemplateRuleData

## SYNOPSIS

Export resource configuration data from Azure templates.

## SYNTAX

```text
Export-AzTemplateRuleData [-TemplateFile] <String> [[-ParameterFile] <String[]>]
 [[-ResourceGroupName] <String>] [[-Subscription] <String>] [[-OutputPath] <String>] [-PassThru]
 [<CommonParameters>]
```

## DESCRIPTION

Export resource configuration data by merging Azure Resource Manager (ARM) template and parameter files.
Template and parameters are merged by resolving template parameters, variables and functions.

By default this is an offline process, requiring no connectivity to Azure.
Some functions that may be included in templates dynamically query Azure for current state.
For these functions standard placeholder values are used by default.

Functions that use placeholders include `subscription`, `resourceGroup`, `reference`, `list*`.

This function does not check template files for strict compliance with Azure schemas.

Currently the following limitations also apply:

- Deployments are not expanded. Deployment is returned instead of resources in deployment.
- The following functions are not supported:
  - Array: `array`, `coalesce`, `createArray`, `intersection`
  - Deployment: `deployment`
  - Resource: `providers`
  - String: `dataUri`, `dataUriToString`
- References to Key Vault secrets are not expanded. A placeholder value is used instead.
- Multi-line strings are not supported.

## EXAMPLES

### Example 1

```powershell
PS C:\> Export-AzTemplateRuleData -TemplateFile .\azuredeploy.json -ParameterFile .\azuredeploy.parameters.json -OutputPath .\out-deploy.json
```

Export resource configuration data based on merging a template and parameter file together.

## PARAMETERS

### -TemplateFile

The absolute or relative file path to an Azure Resource Manager template file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ParameterFile

The absolute or relative file path to one or more Azure Resource Manager template parameter files.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: TemplateParameterFile

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OutputPath

The path to store generated JSON files containing resources.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
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

### -ResourceGroupName

The name of the Resource Group where the deployment will occur.
If this option is specified, the properties of the Resource Group will be looked up and used during export.

This Resource Group specified here will be used to resolve the `resourceGroup()` function.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Subscription

The name of the Subscription where the deployment will occur.
If this option is specified, the properties of the Subscription will be looked up and used during export.

This subscription specified here will be used to resolve the `subscription()` function.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.String[]

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
