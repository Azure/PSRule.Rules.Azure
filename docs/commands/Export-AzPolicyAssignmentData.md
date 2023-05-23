---
external help file: PSRule.Rules.Azure-help.xml
Module Name: PSRule.Rules.Azure
online version: https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/commands/Export-AzPolicyAssignmentData.md
schema: 2.0.0
---

# Export-AzPolicyAssignmentData

## SYNOPSIS

Export policy assignment data.

## SYNTAX

### Default (Default)

```text
Export-AzPolicyAssignmentData [-OutputPath <String>] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Name

```text
Export-AzPolicyAssignmentData [-Name <String>] [-Scope <String>] [-PolicyDefinitionId <String>]
 [-OutputPath <String>] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Id

```text
Export-AzPolicyAssignmentData -Id <String> [-PolicyDefinitionId <String>] [-OutputPath <String>] [-PassThru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### IncludeDescendent

```text
Export-AzPolicyAssignmentData [-Scope <String>] [-IncludeDescendent] [-OutputPath <String>] [-PassThru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This is an **experimental** cmdlet.

Export policy assignment data.

By default the current subscription context will be exported. i.e `Get-AzContext`

Policy assignment data will be exported to the current working directory by default as JSON files,
one per subscription.

All output files include a `.assignment.json` extension by default.

## EXAMPLES

### Example 1

```powershell
Export-AzPolicyAssignmentData
```

```text
Directory: C:\


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a---        26/03/2022   7:01 PM         740098   00000000-0000-0000-0000-000000000000.assignment.json
```

Export policy assignment data from current subscription context.

### Example 2

```powershell
Export-AzPolicyAssignmentData -Name '000000000000000000000000' -Scope '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/PolicyRG'
```

```text
Directory: C:\


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a---        26/03/2022   7:15 PM           4185   00000000-0000-0000-0000-000000000000.assignment.json
```

Export policy assignment with specific name and scope.

### Example 3

```powershell
Export-AzPolicyAssignmentData -Id '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/PolicyRG/providers/Microsoft.Authorization/policyAssignments/000000000000000000000000'
```

```text
Directory: C:\


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a---        26/03/2022   7:42 PM           4185   00000000-0000-0000-0000-00000000000.assignment.json
```

Export policy assignment with specific resource ID.

## PARAMETERS

### -Name

Specifies the name of the policy assignment.

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

Specifies the fully qualified resource ID for the policy assignment.

```yaml
Type: String
Parameter Sets: Id
Aliases: AssignmentId

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scope

Specifies the scope at which the policy is applied for the assignment.

```yaml
Type: String
Parameter Sets: Name, IncludeDescendent
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PolicyDefinitionId

Specifies the ID of the policy definition of the policy assignment.

```yaml
Type: String
Parameter Sets: Name, Id
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDescendent

Causes the list of returned policy assignments to include all assignments related to the given scope,
including those from ancestor scopes and those from descendent scopes.

```yaml
Type: SwitchParameter
Parameter Sets: IncludeDescendent
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPath

The path to store generated JSON files containing policy assignment data.

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
When `-PassThru` is specified, JSON files are not created and Azure resource objects are returned to
the pipeline instead.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.IO.FileInfo

Return `FileInfo` for each of the output files created, one per subscription context.
This is the default.

### PSObject

Return an object for each Azure resource, and configuration exported.
This is returned when the `-PassThru` switch is used.

## NOTES

## RELATED LINKS
