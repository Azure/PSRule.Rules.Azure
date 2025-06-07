---
reviewed: 2025-06-07
description: Learn how to create or assign an issue to contribute rules to PSRule for Azure.
discussion: false
---

# Create or assign an issue

Before contributing a new rule, you should create or assign an issue in the [GitHub repository][1].
This helps ensure that your contribution aligns with the project goals and allows for feedback.

If an issue already exists for the rule you want to contribute, you can ask for the issue to be assigned to you.

Tips for logging an issue:

- The issue should include a clear description of the rule you want to contribute, any relevant details,
  and a link to Well-Architected Framework (WAF) guidance that is aligned with the rule.
  All rules in PSRule for Azure are aligned to the [Microsoft Azure Well-Architected Framework][2].
  If you are unsure which pillar your rule aligns with, you can ask in the issue.
- Identify which resource type the rule applies to, such as `Microsoft.Network/networkSecurityGroups` as
  this will help in writing the rule.

  [1]: https://github.com/Azure/PSRule.Rules.Azure/issues/new/choose
  [2]: https://learn.microsoft.com/azure/well-architected/pillars
