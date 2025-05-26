---
reviewed: 2025-05-27
author: BernieWhite
---

# Prerequisites for contributing rules

## Recommended learning

### Intro to Git and GitHub

When contributing you'll need to have a GitHub account and a basic understanding of Git.
Check out the links below to get started.

- Make sure you have a [GitHub account][github-signup].
- GitHub Help:
  - [Git and GitHub learning resources][learn-git].
  - [GitHub Flow Guide][github-flow].
  - [Fork a repo][github-fork].
  - [About Pull Requests][github-pr].

  [learn-git]: https://docs.github.com/get-started/quickstart/git-and-github-learning-resources
  [github-flow]: https://docs.github.com/get-started/quickstart/github-flow
  [github-signup]: https://github.com/signup/free
  [github-fork]: https://docs.github.com/get-started/quickstart/fork-a-repo
  [github-pr]: https://docs.github.com/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests

### Understand the Project Structure

Before you start contributing, it's helpful to understand the organization of the repository.
Some of the most common sub-directories that are worth knowing about include:

- [docs/](https://github.com/Azure/PSRule.Rules.Azure/tree/main/docs) &mdash; All documentation lives written in markdown.
  - [en/rules/](https://github.com/Azure/PSRule.Rules.Azure/tree/main/docs/en/rules) &mdash; Markdown files for each rule.
  - [CHANGELOG-v1.md](https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/CHANGELOG-v1.md) &mdash; Change log.
- [samples/](https://github.com/Azure/PSRule.Rules.Azure/tree/main/samples) &mdash; Community samples.
- [src/PSRule.Rules.Azure/](https://github.com/Azure/PSRule.Rules.Azure/tree/main/src/PSRule.Rules.Azure) &mdash; Module source code.
  - [rules/](https://github.com/Azure/PSRule.Rules.Azure/tree/main/src/PSRule.Rules.Azure/rules) &mdash; Rule source code.
- [tests/PSRule.Rules.Azure.Tests/](https://github.com/Azure/PSRule.Rules.Azure/tree/main/tests/PSRule.Rules.Azure.Tests) &mdash; Tests for rules and modules features.

## Required tooling

### Using GitHub Codespaces

If you have access to GitHub Codespaces, you can use it to contribute to PSRule for Azure.
This allows you to work in a pre-configured environment without needing to set up your local machine.
Otherwise you can follow the instructions below to set up your local development environment.

### Set up your local development environment

PSRule for Azure requires the following dependencies for development:

- **.NET SDK 8.0** &mdash; is used for building the project and core features.
- **PowerShell** &mdash; is used for building the project, running the rules tests, and development of some rules.
- **Az PowerShell module** &mdash; is used for exporting Azure resources and policies (in-flight).

To install development dependencies, refer to the [installation guide][2].

  [2]: https://azure.github.io/PSRule.Rules.Azure/install/#development-dependencies

## Fork and clone the repository

To start contributing, the first step is to fork the repository to your GitHub account and then clone it to your local machine.

1. **Fork the repository** &mdash; [:octicons-repo-forked-24: Fork][1].
2. **Clone your fork** &mdash; Once the repository is forked, clone it to your local machine.

```bash title="Git"
git clone https://github.com/YOUR_USERNAME/PSRule.Rules.Azure.git
cd PSRule.Rules.Azure
```

  [1]: https://github.com/Azure/PSRule.Rules.Azure/fork
