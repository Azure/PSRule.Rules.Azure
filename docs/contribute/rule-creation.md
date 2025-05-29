---
reviewed: 2025-05-27
author: BernieWhite
---

# Create or update a rule

This article describes the steps for creating or updating a rule in PSRule for Azure.

## Choosing the rule format for new rules

PSRule for Azure supports creating rules YAML or PowerShell formats.
When choosing between YAML or PowerShell to create new rules,
YAML is preferred because it is easier to read and write for simple rules.
This makes it accessible to a wider audience, including those who may not be familiar with PowerShell scripting.

For more complex rules, PowerShell may be required.
Some examples of complex rules that may require PowerShell include:

- Rules that can be customized with configuration.
- Rules that read sub-resources/ child resources.
- Rules that check for availability zones.

### File naming and location

All rules are stored in the `src/PSRule.Rules.Azure/rules/` sub-directory and are named using the following format:

- `Azure.service.Rule.yaml` for YAML rules.
- `Azure.service.Rule.ps1` for PowerShell rules.

The `service` part of the name should be replaced with a short name for the the Azure service that the rule applies to.
For example, `Storage` would be `Azure.Storage.Rule.ps1`.

In each file, any number of rules can be defined, however large services may be organized into multiple files.
Additionally, some services may have both YAML `.Rule.yaml` and PowerShell `.Rule.ps1` files.

### Snippet for new files

When creating a new rule file, you can use the following boilerplate code to get started.

=== "YAML"

    ```yaml
    # Copyright (c) Microsoft Corporation.
    # Licensed under the MIT License.

    #
    # Rules for service
    #

    ---
    # Synopsis: synopsis
    apiVersion: github.com/microsoft/PSRule/v1
    kind: Rule
    metadata:
      name: Azure.service.name
      ref: AZR-000nnn
      tags:
        release: GA
        ruleSet: rule_set
        Azure.WAF/pillar: pillar
    spec:
      type:
        - type
      condition:
        
    ```

=== "PowerShell"

    ```powershell
    # Copyright (c) Microsoft Corporation.
    # Licensed under the MIT License.

    #
    # Rules for service
    #

    # Synopsis: synopsis
    Rule 'Azure.service.name' -Type 'type' -Tag @{ release = 'GA'; ruleSet = 'rule_set'; 'Azure.WAF/pillar' = 'pillar'; } {
        # condition
    }
    ```



