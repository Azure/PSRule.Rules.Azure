---
external help file: PSRule.Rules.Azure-help.xml
Module Name: PSRule.Rules.Azure
online version: https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/commands/Export-AzPolicyAssignmentRuleData.md
schema: 2.0.0
---

# Export-AzPolicyAssignmentRuleData

## SYNOPSIS

Export JSON based rules from policy assignment data.

## SYNTAX

```text
Export-AzPolicyAssignmentRuleData [-Name <String>] -AssignmentFile <String>
 [-ResourceGroup <ResourceGroupReference>] [-Subscription <SubscriptionReference>] [-OutputPath <String>]
 [-RulePrefix <String>] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION

This is an **experimental** cmdlet.

Export JSON based rules from policy assignment data.

Policy assignment data generated from `Export-AzPolicyAssignmentData` is used to generate JSON rules.

By default this is an offline process, requiring no connectivity to Azure.

Policy definitions with the `Disabled` effect are ignored.

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

The rule prefix `Azure` is also applied to the policy names unless overridden with `-RulePrefix` or `AZURE_POLICY_RULE_PREFIX`
in configuration.

Currently the following limitations apply:

- `field()` expressions are not expanded.
- Field/Value count expressions are not supported.
- Template functions with `value` cannot be expanded e.g. `"value": "[substring(field('name'), 0, 3)]"`.
- Any of the above will lead to errors when emitting JSON rules.

## EXAMPLES

### Example 1

```powershell
Export-AzPolicyAssignmentRuleData -Name "policy" -AssignmentFile .\00000000-0000-0000-0000-000000000000.assignment.json
```

```text
Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a---        26/03/2022   9:41 PM            361   definitions-policy.Rule.jsonc
```

Export JSON rules to file in current working directory.

### Example 2

```powershell
$subscription = @{
  subscriptionId = 'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn'
  displayName = 'My Azure Subscription'
  tenantId = 'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn'
}

Export-AzPolicyAssignmentRuleData -Name "policy" -AssignmentFile .\00000000-0000-0000-0000-000000000000.assignment.json -Subscription $subscription
```

```text
Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a---        26/03/2022   9:41 PM            361   definitions-policy.Rule.jsonc
```

Export JSON rules to file in current working directory using a specific subscription.

### Example 3

```powershell
Get-AzPolicyAssignmentDataSource | Export-AzPolicyAssignmentRuleData
```

```text
Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a---        27/03/2022  11:26 AM            721   definitions-export-1b474938.Rule.jsonc
```

Export JSON rules from the current working directory using discovered assignment sources in the
current working directory.

## PARAMETERS

### -Name

The name of the assignment.
If not specified `export-<xxxxxxxx>` will be used as the name of the assignment.

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

### -AssignmentFile

The absolute or relative path to an assignment data file.

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

### -OutputPath

The path to store generated JSON files containing resources.

If this parameter is not specified, output will be written to the current working path.
The file name `definitions-<name>.Rule.jsonc` will be used when this parameter is not set or a directory
is specified.
Where `<name>` is the name of the assignment specified by `-Name`.

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

### -RulePrefix

By default, policy rule names use the `Azure` prefix e.g. `Azure.Policy.e749c2d003da`.

When `-RulePrefix` is specified, the default prefix is overridden.

For example, with `-RulePrefix 'CustomPolicyPrefix'` this would generate the policy rule name `CustomPolicyPrefix.Policy.e749c2d003da`.

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

### -ResourceGroup

A name or hashtable of the Resource Group in the assignment data file.
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

The name or hashtable of the Subscription in the assignment data file.
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

## OUTPUTS

### System.IO.FileInfo

### System.Object

## NOTES

## RELATED LINKS
