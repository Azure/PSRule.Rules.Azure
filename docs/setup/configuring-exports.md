---
author: BernieWhite
---

# Configuring exports

For in-flight analysis or when using policy as rules data may be exported from one or more subscriptions.
To configure the export process see the following configuration options.

To use a configuration option, you **must** use the minimum version specified.
Earlier versions of PSRule for Azure will ignore the configuration option.

## General

### PSRULE_AZURE_RESOURCE_MODULE_NOWARN

<!-- module:version v1.38.0 -->

This configuration option suppresses a warning when the minimum version of `Az.Resources` module is not installed.
Unlike most options, this option can only set by environment variable.

Syntax:

```bash
PSRULE_AZURE_RESOURCE_MODULE_NOWARN: boolean
```

Default:

```bash
PSRULE_AZURE_RESOURCE_MODULE_NOWARN: false
```

Example:

=== "GitHub Actions"

    ```yaml
    env:
      PSRULE_AZURE_RESOURCE_MODULE_NOWARN: true
    ```

=== "Azure Pipelines"

    ```yaml
    variables:
    - name: PSRULE_AZURE_RESOURCE_MODULE_NOWARN
      value: true
    ```

=== "PowerShell"

    ```powershell
    $Env:PSRULE_AZURE_RESOURCE_MODULE_NOWARN = 'true'
    ```

=== "Bash"

    ```bash
    export PSRULE_AZURE_RESOURCE_MODULE_NOWARN=true
    ```

## Policy as rules

The following configuration options apply when using policy as rules.

### AZURE_POLICY_IGNORE_LIST

<!-- module:version v1.21.0 -->

This configuration option configures a custom list policy definitions to ignore when exporting policy to rules.
In addition to the custom list, a built-in list of policies are ignored.
The built-in list can be found [here](https://github.com/Azure/PSRule.Rules.Azure/blob/main/data/policy-ignore.json).

Configure this option to ignore policy definitions that:

- Already have a rule defined.
- Are not relevant to testing Infrastructure as Code.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_POLICY_IGNORE_LIST: array
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_POLICY_IGNORE_LIST configuration option
configuration:
  AZURE_POLICY_IGNORE_LIST: []
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Add custom policy definitions to ignore
configuration:
  AZURE_POLICY_IGNORE_LIST:
  - '/providers/Microsoft.Authorization/policyDefinitions/1f314764-cb73-4fc9-b863-8eca98ac36e9'
  - '/providers/Microsoft.Authorization/policyDefinitions/b54ed75b-3e1a-44ac-a333-05ba39b99ff0'
```

### AZURE_POLICY_RULE_PREFIX

<!-- module:version v1.20.0 -->

This configuration option sets the prefix for names of exported rules.
Configure this option to change the prefix, which defaults to `Azure`.

This configuration option will be ignored when `-Prefix` is used with `Export-AzPolicyAssignmentRuleData`.

Syntax:

```yaml title="ps-rule.yaml"
configuration:
  AZURE_POLICY_RULE_PREFIX: string
```

Default:

```yaml title="ps-rule.yaml"
# YAML: The default AZURE_POLICY_RULE_PREFIX configuration option
configuration:
  AZURE_POLICY_RULE_PREFIX: Azure
```

Example:

```yaml title="ps-rule.yaml"
# YAML: Override the prefix of exported policy rules
configuration:
  AZURE_POLICY_RULE_PREFIX: AzureCustomPrefix
```
