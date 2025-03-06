# Getting Started with Documentation

Welcome to the PSRule.Rules.Azure documentation contribution guide!
This walkthrough will help you understand how to update and improve the documentation, including general documentation and rule-specific documentation.
It serves as an extension of the existing [Writing Documentation Guide](https://azure.github.io/PSRule.Rules.Azure/license-contributing/writing-documentation/).

## Why Contribute to Documentation? 

Good documentation is essential for helping new users and contributors understand how to use PSRule.Rules.Azure effectively.
By contributing, you make it easier for others to get started, understand rules, and use them correctly.

## Prerequisites

Before you start contributing, make sure you have:

- A **GitHub account**
- A **fork of the repository**
- **Git installed** on your system
- A basic understanding of **Markdown**

## Locating Documentation Files

The documentation is stored in the `docs/` directory.
Some key areas you might like to improve include:

- **Rule recommendations:** `docs/en/rules/`
- **Scenarios and examples:** `docs/customization/` and `docs/scenarios/`
- **PowerShell cmdlet and conceptual topics:** `docs/commands/` and `docs/concepts/`
- **General contribution guidelines:** [`docs/license-contributing/contributing.md`](https://azure.github.io/PSRule.Rules.Azure/license-contributing/contributing/)
- **Writing documentation:** [`docs/license-contributing/writing-documentation.md`](https://azure.github.io/PSRule.Rules.Azure/license-contributing/writing-documentation/)

## How to Update Documentation

Follow these steps to make and submit updates:

1. **Fork and clone the repository**

   ```sh
   git clone https://github.com/YOUR_GITHUB_USERNAME/PSRule.Rules.Azure.git
   cd PSRule.Rules.Azure
   ```

2. **Create a new branch for your changes**

   ```sh
   git checkout -b docs-update
   ```

3. **Find the relevant documentation file**
   Navigate to `docs/license-contributing/` for general documentation, `docs/rules/` for rule-specific documentation, or other locations mentioned above.

4. **Edit the file using Markdown**  
   Use a text editor like VS Code or a Markdown editor to make changes.

5. **Update `mkdocs.yml`**
   Ensure that the new documentation page is included in the `mkdocs.yml` navigation structure under:
   ```yaml
   - Samples: samples.md
   - License and contributing:
     - Index: license-contributing/index.md
     - Get started contributing: license-contributing/first-contributors-guide.md
     - Writing documentation: license-contributing/writing-documentation.md
     - Getting started with documentation: license-contributing/getting-started-with-documentation.md
     - Past hackathons: license-contributing/hackathons.md
   - Related projects: related-projects.md
   ```

6. **Preview changes locally**
   If using **MkDocs**, run:
   ```sh
   mkdocs serve
   ```
   Open `http://127.0.0.1:8000/` in your browser to preview.

7. **Commit and push your changes**
   ```sh
   git add docs/license-contributing/getting-started-with-documentation.md mkdocs.yml
   git commit -m "Updated Getting Started with Documentation guide and mkdocs.yml"
   git push origin docs-update
   ```

8. **Create a Pull Request (PR)**
   - Go to your fork on GitHub.
   - Click **"Compare & pull request"**.
   - Provide a clear title and description.
   - Submit the PR and wait for review.

## Best Practices for Writing Documentation

- **Keep it simple** – Use clear and concise language.
- **Follow the existing structure** – Stay consistent with current documentation.
- **Use examples** – Help users understand with practical examples.
- **Check formatting** – Ensure correct Markdown syntax.
- **Preview before submitting** – Avoid typos and formatting errors.

## Troubleshooting Common Issues

| Issue | Solution |
|-------|----------|
| Formatting errors | Use a Markdown linter or preview the file before committing. |
| Merge conflicts | Rebase with the latest `main` branch. |
| PR feedback required | Make requested changes and push again. |

## Conclusion

Contributing to documentation is a great way to support the PSRule.Rules.Azure community.
By improving documentation, you help new users onboard faster and enhance the project's usability.
Thank you for contributing!
