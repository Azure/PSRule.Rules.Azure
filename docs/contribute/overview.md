---
reviewed: 2025-05-27
title: Contribution process overview
description: Learn how to contribute to PSRule for Azure.
author: BernieWhite
---

# Process overview

This article describes the process for contributing to PSRule for Azure based on the type of contribution you want to make.
Anyone can contribute to PSRule for Azure, whether you are a new or experienced user.

- [Contributing rules](#contributing-rules) &mdash; How to contribute new or updated rules to PSRule for Azure.

## Contributing rules

To contribute new or updated rules to PSRule for Azure, follow these steps:

1. **Create an issue** &mdash; Before writing a rule, create an issue to discus a new or existing rule.
   If an issue already exists for the rule you want to contribute, you can skip this step.
   - This helps ensure that your contribution aligns with the project goals and allows for feedback.
   - The issue should include a clear description of the rule you want to contribute, any relevant details,
     and a link to Well-Architected Framework (WAF) guidance that is aligned with the rule.
     All rules in PSRule for Azure are aligned to the [Microsoft Azure Well-Architected Framework][1].
     If you are unsure which pillar your rule aligns with, you can ask in the issue.
   - Identify which resource type the rule applies to, such as `Microsoft.Network/networkSecurityGroups` as
     this will help in writing the rule.
2. **Find the next rule number** &mdash; When adding new rules you must choose the next available unique identifier for each rule.
3. **Create or update a rule** &mdash; Once the issue is created, you can start writing the rule code in YAML or PowerShell.
4. **Create or update rule documentation** &mdash; Each rule must include help documentation that is aligned to the WAF written in markdown.
5. **Create or update tests** &mdash; Each rule must include unit tests to ensure the rule works as expected.
   - The tests should cover positive and negative scenarios.
   - Tests should be written in PowerShell and placed in the `tests/PSRule.Rules.Azure.Tests/` directory.
6. **Update the change log** &mdash; If you are adding a new rule or updating an existing rule, update the `docs/changelog.md` file.
   The change log not only allows users to see what has changes, but also helps maintainers recognize contributions with each release.
   - The change log should include a very brief description of the rule, your GitHub username, and a link to the issue.
7. **Create a pull request** &mdash; Once the rule, documentation, and tests are complete, create a pull request (PR) to merge your changes into the `main` branch of `Azure/PSRule.Rules.Azure`.

  [1]: https://learn.microsoft.com/azure/well-architected/pillars
