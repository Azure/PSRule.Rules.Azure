---
reviewed: 2025-06-03
title: Choosing identifiers for rules
description: Learn how to assign unique rule identifiers when contributing new rules to PSRule for Azure.
discussion: false
---

# Choosing identifiers

When contributing new rules to PSRule for Azure, you need to choose unique identifiers for each rule.
If you are updating an existing rule, you do not need to change the identifiers unless the existing name is no longer appropriate.

All rules in PSRule for Azure have a two unique identifiers a _name_ and a _reference identifier_.
These identifiers are used to unique identify the files for each rule, allow customers to find rules,
and to assist with rule management.

- **Name** &mdash; start with the prefix `Azure.` and identify the service/ resource.
  For example, `Azure.Storage.SoftDelete` identifies the rule for soft delete of Azure Storage accounts.
  The rule name can change over time, for example an Azure service may be renamed or a more descriptive name may be chosen.
  The following restrictions apply to the name:
  - Must start with `Azure.`
  - Must be unique across all rules.
  - Must be a maximum of 35 characters.
- **Reference identifier** &mdash; is a numbered identifier in the format `AZR-nnnnnn`, such as `AZR-000197`.
  The reference identifier is a stable identifier assigned for the life of the rule.
  This identifier does not change and will not be reused.
  The following restrictions apply to the reference identifier:
  - Must start with `AZR-`.
  - Must be followed by a six-digit number, that is sequentially assigned.
  - Must be unique across all rules.

## Choosing a rule name

When choosing a rule name, follow these guidelines:

- The name is composed of three parts, for example `Azure.Storage.SoftDelete`:
  - The prefix `Azure`.
  - The service or resource name, such as `Storage`.
  - A descriptive suffix, such as `SoftDelete`.
- Use a name that is descriptive of the rule's purpose but concise.
- Use camel case to make it more readable.

!!! Tip
    If you are unsure about the name you want to use,
    you can ask a question in the rule issue by tagging the `@Azure/psrule-rules-azure` team for assistance.

## Finding the next reference identifier

The reference identifier is a sequential number that is assigned to each rule.
To find the next available reference identifier, follow these steps:

1. Open the [reference](https://azure.github.io/PSRule.Rules.Azure/en/rules/) page.
2. Scroll to the bottom of the page to find the last rule listed.
3. The last rule will have a reference identifier in the format `AZR-nnnnnn`, such as `AZR-000197`.
4. The next available reference identifier is the last number incremented by one.
