---
external help file: PSRule.Rules.Azure-help.xml
Module Name: PSRule.Rules.Azure
online version: https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/commands/Get-AzPolicyAssignmentDataSource.md
schema: 2.0.0
---

# Get-AzPolicyAssignmentDataSource

## SYNOPSIS

Get policy assignment sources.

## SYNTAX

```text
Get-AzPolicyAssignmentDataSource [-InputPath <String[]>] [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION

This is an **experimental** cmdlet.

Get policy assignment sources. By default `*.assignment.json` sources are discovered from the current
working directory.

## EXAMPLES

### Example 1

```powershell
Get-AzPolicyAssignmentDataSource
```

```text
AssignmentFile
--------------
C:\00000000-0000-0000-0000-000000000001.assignment.json
C:\Users\user\00000000-0000-0000-0000-000000000002.assignment.json
```

Gets policy assignment sources from any `*.assignment.json` sources within any folder in the current
working directory path.

## PARAMETERS

### -InputPath

A path or filter to search for assignment files within the path specified by `-Path`.
By default, files with `*.assignment.json` suffix will be used.

When searching for assignment files all sub-directories will be scanned.
To perform a shallow search, prefix input paths with `./`.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: f, AssignmentFile, FullName

Required: False
Position: Named
Default value: '*.assignment.json'
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -Path

Sets the path to search for assignment files in.
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

### PSRule.Rules.Azure.Pipeline.PolicyAssignmentSource

## NOTES

## RELATED LINKS
