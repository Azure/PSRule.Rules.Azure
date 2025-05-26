# Writing documentation

PSRule for Azure contains documentation ranging from conceptual, code examples, to recommendations.
All of this documentation is written in markdown, open source, and available for you to contribute to.

Some of the documentation that you might like to improve includes:

- Rule recommendations (`docs/en/rules/`).
- Scenarios and examples (`docs/customization/` and `docs/scenarios/`).
- PowerShell cmdlet and conceptual topics (`docs/commands/` and `docs/concepts/`).

!!! Abstract
    This topic covers contributing documentation in PSRule for Azure.

## Rule help

PSRule for Azure includes recommendations and expanded documentation with each rule.
The recommendations are written in markdown and consumed by PSRule during analysis.
This allows us to present easy to read web documentation without writing it separately for analysis.

As a result, PSRule does require rule documentation to be structured in a standard way.
Also we have standards about the metadata we required to ensure there is consistency across documentation.

Some key points for writing rule help:

- **Aligned** &mdash; PSRule for Azure is aligned to the Microsoft Azure Well-Architected Framework (WAF).
- **Actionable** &mdash; Any recommendations **must** be clear and actionable.
  The reader must be able to understand:
  - What has been detected as an issue.
  - Why it is considered an issue.
- **Learn by examples** &mdash; For most cases, recommendations should include Azure Bicep and template examples.
  Optionally CLI or PowerShell command reference may be included.
  Examples should be as concise as possible.
- **Documentation references** &mdash; Each recommendation **must** include references to the WAF.
  Additionally consider adding:
  - Links to provide more detail about the service feature.
  - Azure deployment reference.

Please read our [contributing guidelines][2] and [code of conduct][3] to learn how to contribute.

  [2]: https://github.com/Azure/PSRule.Rules.Azure/blob/main/CONTRIBUTING.md
  [3]: https://github.com/Azure/PSRule.Rules.Azure/blob/main/CODE_OF_CONDUCT.md
