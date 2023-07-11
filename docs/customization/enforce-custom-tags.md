---
author: BernieWhite
---

# Enforcing custom tags

With PSRule, you can layer on custom rules with to implement organization specific requirements.
These custom rules work side-by-side with PSRule for Azure.

Use of resource and resource group tags is recommended in the WAF, however implementations may vary.
You may want to use PSRule to enforce tagging or something similar early in a DevOps pipeline.

!!! Abstract
    The following scenario shows how to create a custom rule to validate Resource Group tags.
    The scenario walks you through the process so that you can apply the same concepts for similar requirements.

## Creating a new rule

Within the `.ps-rule` sub-directory create a new file called `Org.Azure.Rule.ps1`.
Use the following snippet to populate the rule file:

```powershell
# Synopsis: Resource Groups must have all mandatory tags defined.
Rule 'Org.Azure.RG.Tags' -Type 'Microsoft.Resources/resourceGroups' {
    $hasTags = $Assert.HasField($TargetObject, 'Tags')
    if (!$hasTags.Result) {
        return $hasTags
    }

    # <Code for custom tags goes here>
}
```

Some key points to call out with the rule snippet include:

- The name of the rule is `Org.Azure.RG.Tags`.
  Each rule name must be unique.
- The rule applies to resources with the type of `Microsoft.Resources/resourceGroups`.
  i.e. Resource Groups.
- The synopsis comment above the rule is read and used as the default recommendation if the rule fails.
  The rule recommendation appears in output and is intended as an instruction to remediate the failure.
- The assertion `$Assert.HasField` ensures that Resource Group has a tags property.
- The automatic variable `$TargetObject` automatically exposes the current resource being processed.

!!! Tip
    For recommendations on naming and storing rules see [storing custom rules][1].

  [1]: storing-custom-rules.md

## Adding mandatory tags

To require specific tags to be configured on Resource Groups append this code to the rule.

```powershell
# Require tags be case-sensitive
$Assert.HasField($TargetObject.tags, 'costCentre', <# case-sensitive #> $True)
$Assert.HasField($TargetObject.tags, 'env', $True)
```

Some key points to call out include:

- The `$Assert.HasField` assertions are case-sensitive which differs from the previous snippet.
- A list of supported assertions can be found [here][assertions].
- Comments can be added just like normal PowerShell code.

???+ Example "Updated Rule"
    The updated rule should look like:

    ```powershell
    # Synopsis: Resource Groups must have all mandatory tags defined.
    Rule 'Org.Azure.RG.Tags' -Type 'Microsoft.Resources/resourceGroups' {
        $hasTags = $Assert.HasField($TargetObject, 'Tags')
        if (!$hasTags.Result) {
            return $hasTags
        }

        # Require tags be case-sensitive
        $Assert.HasField($TargetObject.tags, 'costCentre', <# case-sensitive #> $True)
        $Assert.HasField($TargetObject.tags, 'env', $True)
    }
    ```

## Limiting tags values

To require these tags to only accept allowed values, append this code to the rule.

```powershell
<#
The costCentre tag must:
- Start with a letter.
- Be followed by a number between 10000-9999999999.
#>
$Assert.Match($TargetObject, 'tags.costCentre', '^([A-Z][1-9][0-9]{4,9})$', $True)

# Require specific values for environment tag
$Assert.In($TargetObject, 'tags.env', @(
    'dev',
    'prod',
    'uat'
), $True)
```

Some key points to call out include:

- Each of these assertions for the field value are case-sensitive.
- Assertions can automatically traverse fields be using the dotted syntax.
i.e. `tags.costCentre`.

???+ Example "Completed rule"
    The completed rule should look like:

    ```powershell
    # Synopsis: Resource Groups must have all mandatory tags defined.
    Rule 'Org.Azure.RG.Tags' -Type 'Microsoft.Resources/resourceGroups' {
        $hasTags = $Assert.HasField($TargetObject, 'Tags')
        if (!$hasTags.Result) {
            return $hasTags
        }

        # Require tags be case-sensitive.
        $Assert.HasField($TargetObject.tags, 'costCentre', <# case-sensitive #> $True)
        $Assert.HasField($TargetObject.tags, 'env', $True)

        <#
        The costCentre tag must:
        - Start with a letter.
        - Be followed by a number between 10000-9999999999.
        #>
        $Assert.Match($TargetObject, 'tags.costCentre', '^([A-Z][1-9][0-9]{4,9})$', $True)

        # Require specific values for environment tag.
        $Assert.In($TargetObject, 'tags.env', @(
            'dev',
            'prod',
            'uat'
        ), $True)
    }
    ```

## Binding type

Rules packaged within PSRule for Azure will automatically detect Resource Groups by their type properties.
Standalone rules will get their type binding configuration from `ps-rule.yaml` instead.

To configure type binding:

- Create/ update the `ps-rule.yaml` file within the root of the repository.
- Add the following configuration snippet.

```yaml
# Configure binding options
binding:
  targetType:
  - 'resourceType'
  - 'type'
```

Some key points to call out include:

- Configuring the binding for `targetType` allows rules to use the `-Type` parameter.
Our custom rule uses `-Type 'Microsoft.Resources/resourceGroups'`.
- The binding configuration will use the `resourceType` property if it exists,
alternative it will use `type`.
If neither property exists, PSRule will use the object type.

## Testing locally

To test the custom rule within Visual Studio Code, see [How to install PSRule for Azure][3].
Alternatively you can test the rule manually by running the following from a PowerShell terminal.

```powershell
Assert-PSRule -Path '.ps-rule/' -Module 'PSRule.Rules.Azure' -InputPath . -Format File
```

  [3]: ../install.md#with-visual-studio-code

## Sample code

Grab the full sample code for each of these files from:

- [Org.Azure.Rule.ps1](https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/customization/enforce-custom-tags/.ps-rule/Org.Azure.Rule.ps1)
- [ps-rule.yaml](https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/customization/enforce-custom-tags/ps-rule.yaml)

[AWAF]: https://learn.microsoft.com/azure/architecture/framework/
[assertions]: https://microsoft.github.io/PSRule/v2/commands/PSRule/en-US/Assert-PSRule/
