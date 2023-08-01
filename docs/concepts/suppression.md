---
description: This topic covers how you can configure PSRule to ignore files, specific rules, or rules for special cases.
author: BernieWhite
---

# Suppression and excluding rules

By default, PSRule will attempt to read and test all files.
You can configure options to:

- Control which files PSRule tests.
- Disable specific rules that don't apply to your environment.
- Configure exceptions for special cases.

!!! Abstract
    This topic covers how you can configure PSRule to ignore files, specific rules, or rules for special cases.

## Excluding a rule

[:octicons-book-24: Docs][1]

You can **exclude** a rule to effectively _disable_ the rule.
When excluded, a rule is not used to test any Azure resources.

To exclude a rule, set the `Rule.Exclude` option within the `ps-rule.yaml` file.

```yaml title="ps-rule.yaml"
rule:
  exclude:
  # Ignore the following rules for all resources
  - Azure.VM.UseHybridUseBenefit
  - Azure.VM.Standalone
```

  [1]: https://aka.ms/ps-rule/options#ruleexclude

## Suppress a rule individually

[:octicons-book-24: Docs][2]

You can **suppress** a rule to effectively _skip_ or _ignore_ a rule for a specific case or exception.

To suppress a rule, set `Suppression` option within the `ps-rule.yaml` file.
PSRule allows you to specify the name of the rule and the name of the resources that will be suppressed.

```yaml title="ps-rule.yaml"
suppression:
  Azure.Storage.SoftDelete:
  # Ignore soft delete on the following non-production storage accounts
  - storagedeveus6jo36t
  - storagedeveus1df278
```

!!! Tip
    Use comments within `ps-rule.yaml` to describe the reason why rules are excluded or suppressed.
    Meaningful comments help during peer review within a Pull Request (PR).
    Also consider including a date if the exclusions or suppressions are temporary.

  [2]: https://aka.ms/ps-rule/options#suppression

## Suppressing common cases

[:octicons-book-24: Docs][3]

If you need to commonly suppress a rule for multiple resources you can use a Suppression Group.
A Suppression Group allow you to define a condition for when a rule should be suppressed.

!!! Example
    For example, suppose you want to suppress the `Azure.Storage.SoftDelete` rule for Storage Accounts based on a tag.

A Suppression Group can be defined within a `.Rule.yaml` file within the `.ps-rule/` sub-directory.
Create this directory in your repository or current working path if it doesn't already exist.

```yaml title=".ps-rule/Suppression.Rule.yaml"
---
# Synopsis: Ignore soft delete for development storage accounts
apiVersion: github.com/microsoft/PSRule/v1
kind: SuppressionGroup
metadata:
  name: Local.IgnoreNonProdStorage
spec:
  rule:
  - Azure.Storage.SoftDelete
  if:
    field: tags.env
    equals: dev
```

!!! Learn
    To learn more, see [suppression groups][3] and [expressions][4].

  [3]: https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_SuppressionGroups/
  [4]: https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_Expressions/

## Ignoring files

[:octicons-book-24: Docs][5]

To exclude or ignore files from being processed, configure the [Input.PathIgnore][5] option.
This option allows you to ignore files using a path spec.

To ignore files with common extensions, set the `Input.PathIgnore` option within the `ps-rule.yaml` file.

```yaml title="ps-rule.yaml"
input:
  pathIgnore:
  # Exclude files with these extensions
  - '*.md'
  - '*.png'
  # Exclude specific configuration files
  - 'bicepconfig.json'
```

To ignore all files with some exceptions, set the `Input.PathIgnore` option within the `ps-rule.yaml` file.

```yaml title="ps-rule.yaml"
input:
  pathIgnore:
  # Exclude all files
  - '*'
  # Only process deploy.bicep files
  - '!**/deploy.bicep'
```

!!! Tip
    Some common file exclusions are recommended for working with Azure Bicep source files.
    See [Configuring path exclusions][6] for details.

  [5]: https://aka.ms/ps-rule/options#inputpathignore
  [6]: ../using-bicep.md#configuring-path-exclusions
