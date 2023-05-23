---
external help file: PSRule.Rules.Azure-help.xml
Module Name: PSRule.Rules.Azure
online version: https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/commands/Get-AzRuleTemplateLink.md
schema: 2.0.0
---

# Get-AzRuleTemplateLink

## SYNOPSIS

Get a metadata link to a Azure template file.

## SYNTAX

```text
Get-AzRuleTemplateLink [[-InputPath] <String[]>] [-SkipUnlinked] [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION

Gets a link between an Azure Resource Manager (ARM) parameter file and its referenced template file.
Parameter files reference a template file by defining metadata.
Alternatively, template files are discovered by naming convention.

By default, when parameter files without a matching template are discovered an error is raised.

To reference a template, set the `metadata.template` property to a file path.
Referencing templates outside of the path specified with `-Path` is not permitted.

To discover template files by naming convention:

- Both template and parameter files must be in the same sub-directory.
- The parameter file must end with `.parameters.json`.
- The parameter file must be named `<templateName>.parameters.json`.
- The template file must be named `<templateName>.json`.

For more information see the about_PSRule_Azure_Metadata_Link topic.

## EXAMPLES

### Example 1

```powershell
Get-AzRuleTemplateLink
```

Get links from any `*.parameters.json` files within any folder in the current working path.

## PARAMETERS

### -InputPath

A path or filter to search for parameter files within the path specified by `-Path`.
By default, files with `*.parameters.json` suffix will be used.

When searching for parameter files all sub-directories will be scanned.
To perform a shallow search, prefix input paths with `./`.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: f, TemplateParameterFile, FullName

Required: False
Position: 1
Default value: '*.parameters.json'
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -SkipUnlinked

Use this option to ignore parameter files that have no matching template.
By default, when parameter files without a matching template are discovered an error is raised.

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

### -Path

Sets the path to search for parameter files in.
By default, this is the current working path.

```yaml
Type: String
Parameter Sets: (All)
Aliases: p

Required: False
Position: 0
Default value: $PWD
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### PSRule.Rules.Azure.Data.Metadata.ITemplateLink

## NOTES

## RELATED LINKS

[about_PSRule_Azure_Metadata_Link](../concepts/about_PSRule_Azure_Metadata_Link.md)
