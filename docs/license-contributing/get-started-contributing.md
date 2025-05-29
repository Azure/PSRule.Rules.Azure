# Get started contributing

Welcome to PSRule for Azure! We are excited to have you contribute to the project.
This guide will walk you through the process of setting up your local development environment, understanding the project structure, and submitting your first contribution.

## Fork and clone the repository

To start contributing, the first step is to fork the repository to your GitHub account and then clone it to your local machine.

1. **Fork the repository** &mdash; [:octicons-repo-forked-24: Fork][1].
2. **Clone your fork** &mdash; Once the repository is forked, clone it to your local machine.

```bash title="Git"
git clone https://github.com/YOUR_USERNAME/PSRule.Rules.Azure.git
cd PSRule.Rules.Azure
```

  [1]: https://github.com/Azure/PSRule.Rules.Azure/fork

## Set up your local development environment

PSRule for Azure requires the following dependencies for development:

- **.NET SDK 8.0** &mdash; is used for building the project and core features.
- **PowerShell** &mdash; is used for building the project, running the rules tests, and development of some rules.
- **Az PowerShell module** &mdash; is used for exporting Azure resources and policies (in-flight).

To install development dependencies, refer to the [installation guide][2].

  [2]: https://azure.github.io/PSRule.Rules.Azure/install/#development-dependencies

## Understand the Project Structure

Before you start coding, it's helpful to understand the organization of the repository.
Some of the most common sub-directories that are worth knowing about include:

- [docs/](https://github.com/Azure/PSRule.Rules.Azure/tree/main/docs) &mdash; All documentation lives written in markdown.
  - [en/rules/](https://github.com/Azure/PSRule.Rules.Azure/tree/main/docs/en/rules) &mdash; Markdown files for each rule.
  - [CHANGELOG-v1.md](https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/CHANGELOG-v1.md) &mdash; Change log.
- [samples/](https://github.com/Azure/PSRule.Rules.Azure/tree/main/samples) &mdash; Community samples.
- [src/PSRule.Rules.Azure/](https://github.com/Azure/PSRule.Rules.Azure/tree/main/src/PSRule.Rules.Azure) &mdash; Module source code.
  - [rules/](https://github.com/Azure/PSRule.Rules.Azure/tree/main/src/PSRule.Rules.Azure/rules) &mdash; Rule source code.
- [tests/PSRule.Rules.Azure.Tests/](https://github.com/Azure/PSRule.Rules.Azure/tree/main/tests/PSRule.Rules.Azure.Tests) &mdash; Tests for rules and modules features.

## Contributing to Code

Before writing a fix or feature enhancement, ensure that an issue is logged.
Be prepared to discuss your feature and take feedback.
Additionally, ensure that your changes include unit tests and any necessary updates to the documentation.

1. Create a new branch from `main` in your fork for your changes.
2. Add commits in your branch, making sure they are logically grouped and well-described.
3. If you have updated module code or rules, also update the `docs/CHANGELOG-v1.md`.
   - Note: You don't need to update the `docs/CHANGELOG-v1.md` for changes to unit tests or documentation.
4. Build your changes locally before pushing them. This ensures that they work as expected.
5. Create a Pull Request (PR):
   - Once you are ready for your changes to be reviewed, create a PR to merge changes into the `main` branch.
   - If your changes are not ready for review, create a draft pull request instead.
6. The Continuous Integration (CI) process will automatically build your changes.
   Ensure that your changes build successfully to be merged.
   - If there are build errors, push new commits to your branch to fix them.

## Building and testing your changes

Before opening a pull request, it’s important to build and test your changes locally.
PSRule for Azure uses Continuous Integration (CI) pipelines to test changes across MacOS, Linux, and Windows configurations.

1. **Build and test locally** &mdash; Ensure that you can build your changes locally.
   Follow the instructions in the [Building from Source][3] guide to set up your local environment for testing.
2. **Run all tests** &mdash; Before creating your PR, run the tests to make sure your changes are working as expected.

```powershell title="PowerShell"
Invoke-Build Test -AssertStyle Client
```

  [3]: https://azure.github.io/PSRule.Rules.Azure/install/#building-from-source

### Example Unit Test

Here is an example of a unit test for validating rules:
[Azure.ACR.Tests.ps1 Example](https://github.com/Azure/psrule.rules.azure/blob/main/tests/PSRule.Rules.Azure.Tests/Azure.ACR.Tests.ps1#L40-L56)

## Commit your changes

Once your changes are ready, commit your changes to your fork:

```bash title="Git"
git add .
git commit -m "Brief description of your changes"
git push origin YOUR_BRANCH
```

## Submit a pull request (PR)

- Go to your forked repository on GitHub.
- Click on "Compare & pull request."
- In the provided PR template provide a clear and concise description of your changes.

### Review and approval

What you can expect from review and approval of your contribution:

- **Once your PR is submitted** &mdash; project maintainers will review your changes and make suggestions or comments.
  Be prepared to make updates based on feedback until your PR is approved.
  If you are unclear on the feedback you can comment in the PR to get clarification.
- **Automated CI tests** &mdash; for your PR do not run automatically, a maintainer must approve running the workflow.
  Once approved, if any automated CI tests fail be prepared to test your changes locally and update your branch.
  If you get stuck, you can comment in the PR to ask questions.
- **Update your PR** &mdash; by adding commits to your branch and pushing changes to GitHub.
  After a few moments your PR will update with your latest changes.
  Avoid using forced pushes or squashing changes while your PR is active, as this makes it harder to review your changes.
- **Contributor License Agreement (CLA)** &mdash; The Microsoft policy bot may request you accept the CLA.
  Please read and follow the instructions of the bot to complete acceptance of the Microsoft CLA.
  We can not approve and merge your PR if it is flagged by the bot until the CLA is accepted.
- **After PR approval** &mdash; your PR will be merged into the main repository by the maintainers.

## Stay engaged

- Follow discussions and updates by subscribing to issues and PRs.
- Keep up with the latest changes in the project by regularly pulling updates from the upstream repository.
- Share feedback and help others when possible.

## Related content

- [Contributing Guide](https://github.com/Azure/PSRule.Rules.Azure/blob/main/CONTRIBUTING.md) – Detailed guidelines for contributing to the project.
- [PSRule Documentation](https://github.com/microsoft/PSRule) – Learn about the PSRule engine used in this project.
- [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/) – Understand the principles that guide this project.
