---
description: Learn how to create a suppression group to ignore special case NSGs.
author: BernieWhite
---

# Permit outbound management

This article describes how to use a suppression group to suppress special case Network Security Groups (NSGs).
While this article focuses on NSGs, the concept apply to other special cases that might be specific to your environment.

As discussed in [Azure.NSG.LateralTraversal][1], outbound management traffic is expected from some subnets.
Subnets that are expected allow outbound management traffic may include:

- Privileged access workstations (PAWs)
- Bastion hosts
- Jump boxes

As a result, you may want to suppress the [Azure.NSG.LateralTraversal][1] rule on NSGs for these special cases.

  [1]: ../en/rules/Azure.NSG.LateralTraversal.md

## Create a suppression group

Within the `.ps-rule` sub-directory create a file called `Org.Azure.Suppressions.Rule.yaml`.
If the `.ps-rule` sub-directory does not exist, create it in the root of your repository.

Use the following snippet to populate the [suppression group][2]:

```yaml title="YAML"
---
# Synopsis: Ignore NSG lateral movement for management subnet NSGs such as Azure Bastion.
apiVersion: github.com/microsoft/PSRule/v1
kind: SuppressionGroup
metadata:
  name: Org.Azure.PermitOutboundManagement
spec:
  rule:
    - PSRule.Rules.Azure\Azure.NSG.LateralTraversal
  if:
    allOf:
      - type: '.'
        in:
          - Microsoft.Network/networkSecurityGroups

      # Suppress NSGs with bastion or management in their name
      - name: '.'
        contains:
          - bastion
          - management
```

Some key points to call out with the [suppression group][2] snippet include:

- The name of the suppression group is `Org.Azure.PermitOutboundManagement`.
  Each resource name must be unique.
- The suppression group applies to:
  - The rule `PSRule.Rules.Azure\Azure.NSG.LateralTraversal`.
  - Run against NSGs with the type `Microsoft.Network/networkSecurityGroups`.
  - When the name of the NSG contains `bastion` or `management`.
    The [suppression group][2] uses [expressions][3] to determine when a resource is suppressed.
    Update this condition to match your environment.
    For example, the following NSGs would be suppressed by this suppression group:
    - `nsg-bastion-prod-eus-001`
    - `nsg-hub-management-prod-001`
- The synopsis comment above the suppression group is included in output as the explanation for the suppression.

!!! Tip
    [Expressions][3] can be combined within a [suppression group][2] using `allOf` or `anyOf` operators.

  [2]: https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_SuppressionGroups/
  [3]: https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_Expressions/

## Related content

- [Sample: Suppress geo-replication in dev](https://github.com/Azure/PSRule.Rules.Azure/tree/main/samples/suppression/SuppressGeoReplicationInDev)

*[NSGs]: Network Security Groups
*[NSG]: Network Security Group
