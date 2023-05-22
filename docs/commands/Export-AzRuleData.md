---
external help file: PSRule.Rules.Azure-help.xml
Module Name: PSRule.Rules.Azure
online version: https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/commands/Export-AzRuleData.md
schema: 2.0.0
---

# Export-AzRuleData

## SYNOPSIS

Export resource configuration data from one or more Azure subscriptions.

## SYNTAX

### Default (Default)

```text
Export-AzRuleData [[-OutputPath] <String>] [-Subscription <String[]>] [-Tenant <String[]>]
 [-ResourceGroupName <String[]>] [-Tag <Hashtable>] [-PassThru] [-SkipDiscovery] [-ResourceId <String[]>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### All

```text
Export-AzRuleData [[-OutputPath] <String>] [-ResourceGroupName <String[]>] [-Tag <Hashtable>] [-PassThru]
 [-All] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Export resource configuration data from deployed resources in one or more Azure subscriptions.

If no filters are specified then the current subscription context will be exported. i.e. `Get-AzContext`

To export all subscriptions contexts use the `-All` switch.
When the `-All` switch is used, all subscriptions contexts will be exported. i.e. `Get-AzContext -ListAvailable`

Resource data will be exported to the current working directory by default as JSON files, one per subscription.

## EXAMPLES

### Example 1

```powershell
Export-AzRuleData
```

```text
Directory: C:\

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----         1/07/2019 10:03 AM        7304948 00000000-0000-0000-0000-000000000001.json
```

Export resource configuration data from current subscription context.

### Example 2

```powershell
Export-AzRuleData -Subscription 'Contoso Production', 'Contoso Non-production'
```

```text
Directory: C:\

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----         1/07/2019 10:03 AM        7304948 00000000-0000-0000-0000-000000000001.json
-a----         1/07/2019 10:03 AM        7304948 00000000-0000-0000-0000-000000000002.json
```

Export resource configuration data from subscriptions by name.

### Example 3

```powershell
Export-AzRuleData -ResourceGroupName 'rg-app1-web', 'rg-app1-db'
```

```text
Directory: C:\

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----         1/07/2019 10:03 AM        7304948 00000000-0000-0000-0000-000000000001.json
```

Export resource configuration data from two resource groups within the current subscription context.

## PARAMETERS

### -All

By default, resources from the current subscription context are extracted.
Use `-All` to extract resource data for all subscription contexts instead.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath

The path to store generated JSON files containing resources.

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

Optionally filter resources by Resource Group name.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Subscription

Optionally filter resources by subscription, Id or Name.

```yaml
Type: String[]
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag

Optionally filter resources based on tag.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tenant

Optionally filter resources by a unique Tenant identifer.

```yaml
Type: String[]
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceId

A list of resource Ids to expand.

```yaml
Type: String[]
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -SkipDiscovery

Determines if resource discovery is skipped.
When skipped resources are expanded based on provided resource Ids.

```yaml
Type: SwitchParameter
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.IO.FileInfo

Return `FileInfo` for each of the output files created, one per subscription.
This is the default.

### PSObject

Return an object for each Azure resource, and configuration exported.
This is returned when the `-PassThru` switch is used.

## NOTES

## RELATED LINKS
