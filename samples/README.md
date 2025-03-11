# Samples

You have reached the Azure community samples for PSRule.
If you have a question about these samples, please start a discussion on GitHub.

These samples are broken into the following categories:

- `baselines/` - Sample baselines that can be used to create a baseline for Azure resources.
- `rules/` - Sample rules not shipped with PSRule for Azure.
  These samples do no align to Azure Well-Architected Framework (WAF),
  and should be considered as a starting point for custom rules.
- `suppression/` - Sample suppression groups that can be used to suppress rules in PSRule for Azure.

## Contributing samples

Additional samples can be contributed.
Please use the following structure for your `README.md`.
Replace the comment placeholders with details about your sample.

```markdown
---
author: <github_username>
---

# <title>

<!-- a short one line description which will be included in table of contents -->

## Summary

<!-- describe what your sample does -->

## Usage

<!-- how to use your sample -->

## References

<!-- references to docs that help explain the detail. here is a few to get started, but remove if they are not relevant. -->

- [Using custom rules](https://azure.github.io/PSRule.Rules.Azure/customization/using-custom-rules/)
- [Conventions](https://microsoft.github.io/PSRule/v2/concepts/PSRule/en-US/about_PSRule_Conventions/#including-with-options)
```

When contributing a sample:

- README.md:
  - Please update `author:` with your GitHub username to be credited in the table of contents.
  - Please give the sample a title.
- Store each sample in a unique folder. i.e. `samples/<category>/<your_sample>`.
- Prefix your sample rule or convention files with your folder name. i.e. `<your_sample>.Rule.ps1`.
