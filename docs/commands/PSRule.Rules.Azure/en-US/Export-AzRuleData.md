---
external help file: PSRule.Rules.Azure-help.xml
Module Name: PSRule.Rules.Azure
online version:
schema: 2.0.0
---

# Export-AzRuleData

## SYNOPSIS

Export resource configuration data from one or more Azure subscriptions.

## SYNTAX

```text
Export-AzRuleData [[-OutputPath] <String>] [[-Subscription] <String[]>] [[-Tenant] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION

Export resource configuration data from one or more Azure subscriptions.

If no filters are specified then all subscription contexts will be exported. i.e. `Get-AzContext -ListAvailable`

Resource data will be exported to the current working directory by default as JSON files, one per subscription.

## EXAMPLES

### Example 1

```powershell
PS C:\> Export-AzRuleData -Subscription 'Contoso Production', 'Contoso Non-production'
```

Export information from subscriptions by name.

## PARAMETERS

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

### -Subscription

Optionally filter resources by subscription, Id or Name.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tenant

Optionally filter resources by a unique Tenant identifer.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
