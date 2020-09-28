---
external help file: PSRule.Rules.Azure-help.xml
Module Name: PSRule.Rules.Azure
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/commands/PSRule.Rules.Azure/en-US/Export-AzTemplateRuleData.md
schema: 2.0.0
---

# Export-AzTemplateRuleData

## SYNOPSIS

Export resource configuration data from Azure templates.

## SYNTAX

```text
Export-AzTemplateRuleData [[-Name] <String>] -TemplateFile <String> [-ParameterFile <String[]>]
 [-ResourceGroupName <String>] [-Subscription <String>] [-OutputPath <String>] [-PassThru] [<CommonParameters>]
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

- Nested templates are expanded, external templates are not.
  - Deployment resources that link to an external template are returned as a resource.
- The `environment`, and `pickZones` template functions are not supported.
- References to Key Vault secrets are not expanded. A placeholder value is used instead.
- Multi-line strings and user-defined functions are not supported.

## EXAMPLES

### Example 1

```powershell
Export-AzTemplateRuleData -TemplateFile .\template.json -ParameterFile .\parameters.json;
```

Export resource configuration data based on merging a template and parameter file together.

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
Parameter Sets: (All)
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
Parameter Sets: (All)
Aliases: TemplateParameterFile

Required: False
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

### -ResourceGroupName

The name of the Resource Group where the deployment will occur.
If this option is specified, the properties of the Resource Group will be looked up and used during export.

This Resource Group specified here will be used to resolve the `resourceGroup()` function.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
Position: Named
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

### System.IO.FileInfo

### System.Object

## NOTES

## RELATED LINKS
