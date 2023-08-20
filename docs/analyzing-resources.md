---
description: Learn how you can test the state of resources already deployed to Azure.
author: BernieWhite
---

# Analyzing resources

The current state of Azure resources can be tested with PSRule for Azure, referred to as _in-flight_ analysis.
This is a two step process that works in high security environments with separation of roles.

!!! Abstract
    This topics covers how you can test the state of deployed Azure resources that have been exported.

!!! Important
    This step requires that you have already exported the state of deployed Azure resources.
    Before continuing, complete [Exporting rule data][1] for the resources that will be tested.

  [1]: export-rule-data.md

## Analyzing exported state

The state of resources can be analyzed for exported state by using the `Invoke-PSRule` PowerShell cmdlet.

For example:

```powershell
Invoke-PSRule -InputPath 'out/' -Module 'PSRule.Rules.Azure';
```

To filter results to only failed rules, use `Invoke-PSRule -Outcome Fail`.
Passed, failed and error results are shown by default.

For example:

```powershell
# Only show failed results
Invoke-PSRule -InputPath 'out/' -Module 'PSRule.Rules.Azure' -Outcome Fail;
```

The output of this example is:

```text
   TargetName: storage

RuleName                            Outcome    Recommendation
--------                            -------    --------------
Azure.Storage.UseReplication        Fail       Storage accounts not using GRS may be at risk
Azure.Storage.SecureTransferRequ... Fail       Storage accounts should only accept secure traffic
Azure.Storage.SoftDelete            Fail       Enable soft delete on Storage Accounts
```

A summary of results can be displayed by using `Invoke-PSRule -As Summary`.

For example:

```powershell
# Display as summary results
Invoke-PSRule -InputPath 'out/' -Module 'PSRule.Rules.Azure' -As Summary;
```

The output of this example is:

```text
RuleName                            Pass  Fail  Outcome
--------                            ----  ----  -------
Azure.ACR.MinSku                    0     1     Fail
Azure.AppService.PlanInstanceCount  0     1     Fail
Azure.AppService.UseHTTPS           0     2     Fail
Azure.Resource.UseTags              73    36    Fail
Azure.SQL.ThreatDetection           0     1     Fail
Azure.SQL.Auditing                  0     1     Fail
Azure.Storage.UseReplication        1     7     Fail
Azure.Storage.SecureTransferRequ... 2     6     Fail
Azure.Storage.SoftDelete            0     8     Fail
```

### Ignoring rules

To prevent a rule executing you can either:

- **Exclude** &mdash; The rule is not executed for any resource.
- **Suppress** &mdash; The rule is not executed for a specific resource by name.

To exclude a rule, set `Rule.Exclude` option within the `ps-rule.yaml` file.

[:octicons-book-24: Docs][3]

```yaml
rule:
  exclude:
  # Ignore the following rules for all resources
  - Azure.VM.UseHybridUseBenefit
  - Azure.VM.Standalone
```

To suppress a rule, set `Suppression` option within the `ps-rule.yaml` file.

[:octicons-book-24: Docs][4]

```yaml
suppression:
  Azure.AKS.AuthorizedIPs:
  # Exclude the following externally managed AKS clusters
  - aks-cluster-prod-eus-001
  Azure.Storage.SoftDelete:
  # Exclude the following non-production storage accounts
  - storagedeveus6jo36t
  - storagedeveus1df278
```

!!! tip
    Use comments within `ps-rule.yaml` to describe the reason why rules are excluded or suppressed.
    Meaningful comments help during peer review within a Pull Request (PR).
    Also consider including a date if the exclusions or suppressions are temporary.

  [3]: https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_Options/#ruleexclude
  [4]: https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_Options/#suppression

### Advanced configuration

[:octicons-book-24: Docs][5]

PSRule for Azure comes with many configuration options.
The setup section explains in detail how to configure each option.

  [5]: setup/configuring-options.md
