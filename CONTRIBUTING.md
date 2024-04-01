# Contributing to PSRule for Azure

Welcome, and thank you for your interest in contributing to PSRule!

There are many ways in which you can contribute, beyond writing code.
The goal of this document is to provide a high-level overview of how you can get involved.

- [Reporting issues](#reporting-issues)
- [Improve documentation](#improving-documentation)
- [Adding or improving rules](#adding-or-improving-rules)
- Fix bugs or add features

## Asking Questions

Have a question? Rather than opening an issue, please ask a question in [discussions][1].
Your well-worded question will serve as a resource to others searching for help.

  [1]: https://github.com/Azure/PSRule.Rules.Azure/discussions

## Reporting issues

Have you identified a reproducible problem?
Have a feature request?
We want to hear about it!
Here's how you can make reporting your issue as effective as possible.

### Identify Where to Report

The PSRule project is distributed across multiple repositories.
Try to file the issue against the correct repository.
Check the list of [related projects][2] if you aren't sure which repository is correct.

  [2]: https://azure.github.io/PSRule.Rules.Azure/related-projects/

### Look for an existing issue

Before you create a new issue, please do a search in [open issues][issues] to see if the issue or feature request has already been filed.

If you find your issue already exists, make relevant comments and add your [reaction][3].
Use a reaction in place of a "+1" comment:

* 👍 - upvote
* 👎 - downvote

  [3]: https://github.blog/2016-03-10-add-reactions-to-pull-requests-issues-and-comments/

## Improving documentation

This project contains a wide range of documentation, stored in `docs/`.
Some of the documentation that you might like to improve include:

- Rule recommendations (`docs/en/rules/`).
- Scenarios and examples (`docs/customization/` and `docs/scenarios/`).
- PowerShell cmdlet and conceptual topics (`docs/commands/` and `docs/concepts/`).

### Markdown formatting

When writing documentation in Markdown, please follow these formatting guidelines:

- Semantically break up long paragraphs into multiple lines, particularly if they contain multiple sentences.
- Add a blank line between paragraphs.
- Add a blank line before and after lists, code blocks, and section headers.

### Rule recommendations

Before improving rule recommendations familiarize yourself with writing [rule markdown documentation][4].
Rule documentation requires the following annotations for use with PSRule for Azure:

- `severity` - A subjective rating of the impact of a rule on the solution or platform.
  *NB* - the severity ratings reflect a productionised implementation, consideration should be applied for pre-production environments.
  
  Available severities are:
  - `Critical` - A 'must have' if the solution is to be considered 'fit for purpose', secure, well governed and managed inline with the Microsoft Azure [Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/).
  - `Important` - A 'to be considered' within the context of the solution and domain.
    In some cases, can introduce cost or complexity that should be considered as a trade off and explicitly documented as a [Key Design Decision](https://learn.microsoft.com/azure/cloud-adoption-framework/decision-guides/).
  - `Awareness` - A 'good to have' feature, normally reserved for solutions with the highest [non-functional requirements](https://learn.microsoft.com/azure/well-architected/reliability/checklist).
  
- `pillar` - A Azure Well-Architected Framework pillar.
  Either `Cost Optimization`, `Operational Excellence`, `Performance Efficiency`, `Reliability`, `Security`.
- `category` - A category of Azure Well-Architected Framework pillar.
- `online version` - The URL of the online version of the documentation.
  This will start with `https://azure.github.io/PSRule.Rules.Azure/en/rules/`.
  The URL will not exist for new rules until the Pull Request is merged.

When authoring and improving rule documentation, please follow these guidelines:

- **Reference the WAF** &mdash; by the pillar recommendation.
  For example if the rule relates to redundancy in the Reliability pillar you could reference [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy).
- **Add relevant links** &mdash; to the Azure service documentation.
  Examples of good documentation links include:
  - Best practices for the Azure service.
  - Instructions on how to configure the Azure service.
  - [Azure deployment reference](https://learn.microsoft.com/azure/templates/).
- **Remove culture** &mdash; from links to _https://learn.microsoft.com/_ to make it more generic.
  This will allow the link to redirect to a language based on the user's settings.
  For example _https://learn.microsoft.com/azure/aks/concepts-scale_ instead of _https://learn.microsoft.com/en-us/azure/aks/concepts-scale_.
- **Add examples** &mdash; of a Azure resource that would pass the rule.
  For rules that apply to pre-flight checks provide an example in Azure Bicep _and_ Azure template format.
  - Additionally if a pre-built Azure Verified Module is available, reference after the Bicep example using a short-code.
    The short-code format is `<!-- external:avm <module_path> <params> -->`.
    For more information see the [example](https://github.com/Azure/PSRule.Rules.Azure/blob/9bb5589bd1ddb01197866d5199f3954cf6f9206b/docs/en/rules/Azure.ContainerApp.MinReplicas.md?plain=1#L113).

  [4]: https://microsoft.github.io/PSRule/latest/authoring/writing-rule-help/#writing-markdown-documentation

## Adding or improving rules

- Rules are stored in `src/PSRule.Rules.Azure/rules/`.
- Rules are organized into separate `.Rule.ps1` or `.Rule.yaml` files based on service.
- Rule documentation in English is stored in `docs/en/rules/`.
  - Additional cultures can be added in a subdirectory under `docs/`.
- Use pre-conditions to limit the type of resource a rule applies to.

Each rule **must** meet the following requirements:

- Named with the `Azure.` prefix.
- The rule name must not be longer than 35 characters.
- Use a unique `Ref` following the format `AZR-nnnnnnn`.
  Where `nnnnnn` is a sequential number from `000001`.
- Have documentation and unit tests.
- Have a `release` tag either `GA` or `preview`. e.g. `-Tag @{ release = 'GA' }`
  - Rules are marked as `GA` if they relate to generally available Azure features.
  - Rules are marked as `preview` if they relate to _preview_ Azure features.
- Have a `ruleSet` tag. e.g. `-Tag @{ release = 'GA'; ruleSet = '2020_09' }`
  - The rule set tag identifies the quarter that the rule was first released.
  - This is used to include rules in quarterly baselines.
  - New rules are included in the next quarterly baseline. i.e. (YYYY_03, YYYY_06, YYYY_09, YYYY_12)
- Include an inline `Synopsis: ` comment above each rule.

For example:

```powershell
# Synopsis: Consider configuring a managed identity for each API Management instance.
Rule 'Azure.APIM.ManagedIdentity' -Type 'Microsoft.ApiManagement/service' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.In($TargetObject, 'Identity.Type', @('SystemAssigned', 'UserAssigned'))
}
```

```yaml
---
# Synopsis: Consider configuring a managed identity for each API Management instance.
apiVersion: github.com/microsoft/PSRule/v1
kind: Rule
metadata:
  name: Azure.APIM.ManagedIdentity
  tags:
    release: 'GA'
    ruleSet: '2020_06'
spec:
  type:
  - Microsoft.ApiManagement/service
  condition:
    field: 'Identity.Type'
    in:
    - 'SystemAssigned'
    - 'UserAssigned'
```

**Tips for authoring rules:**

- To create new rules, snippets in the VS Code extension for PSRule can be used.
- Use `-Type` over `-If` pre-conditions when possible.
Both may be required in some cases.

### Adding rule configuration options

For some rules, adding configuration options to allow customization may be helpful.
When adding configuration options, please follow these guidelines:

- Name the configuration option using by:
  - Prefixing the configuration option name with `AZURE_`.
  - Separating words with `_` to make the configuration option name more readable.
  - Capitalize the configuration option name. e.g. `AZURE_POLICY_WAIVER_MAX_EXPIRY`
- Include relevant documentation for the configuration option in the rule's documentation.
  See [Azure.Policy.WaiverExpiry](docs/en/rules/Azure.Policy.WaiverExpiry.md) for an example.
- Include relevant examples of the configuration option in [Configuring rule defaults](docs/setup/configuring-rules.md).

## Contributing to code

- Before writing a fix or feature enhancement, ensure that an issue is logged.
- Be prepared to discuss a feature and take feedback.
- Include unit tests and updates documentation to complement the change.

When you are ready to contribute a fix or feature:

- Start by [forking the PSRule.Rules.Azure repo][github-fork].
- Create a new branch from main in your fork.
- Add commits in your branch.
  - If you have updated module code or rules also update `CHANGELOG.md`.
  - You don't need to update the `CHANGELOG.md` for changes to unit tests or documentation.
  - Try building your changes locally. See [building from source][build] for instructions.
- [Create a pull request][github-pr-create] to merge changes into the PSRule `main` branch.
  - If you are _ready_ for your changes to be reviewed create a _pull request_.
  - If you are _not ready_ for your changes to be reviewed, create a _draft pull request_.
  - An continuous integration (CI) process will automatically build your changes.
    - You changes must build successfully to be merged.
    - If you have any build errors, push new commits to your branch.
    - Avoid using forced pushes or squashing changes while in review, as this makes reviewing your changes harder.

### Intro to Git and GitHub

When contributing to documentation or code changes, you'll need to have a GitHub account and a basic understanding of Git.
Check out the links below to get started.

- Make sure you have a [GitHub account][github-signup].
- GitHub Help:
  - [Git and GitHub learning resources][learn-git].
  - [GitHub Flow Guide][github-flow].
  - [Fork a repo][github-fork].
  - [About Pull Requests][github-pr].

### Code editor

You should use the multi-platform [Visual Studio Code][vscode] (VS Code).
The project contains a number of workspace specific settings that make it easier to author consistently.

After installing VS Code, install the following extensions:

- [PSRule](https://marketplace.visualstudio.com/items?itemName=bewhite.psrule-vscode-preview)
- [YAML](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)
- [PowerShell](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)
- [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)

### Building and testing

When creating a pull request to merge your changes, a continuous integration (CI) pipeline is run.
The CI pipeline will build then test your changes across MacOS, Linux and Windows configurations.

Before opening a pull request try building your changes locally.
To do this See [building from source][build] for instructions.

### Contributor License Agreement (CLA)

This project welcomes contributions and suggestions. Most contributions require you to
agree to a Contributor License Agreement (CLA) declaring that you have the right to,
and actually do, grant us the rights to use your contribution. For details, visit
https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need
to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the
instructions provided by the bot. You will only need to do this once across all repositories using our CLA.

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Thank You!

Your contributions to open source, large or small, make great projects like this possible.
Thank you for taking the time to contribute.

[learn-git]: https://docs.github.com/get-started/quickstart/git-and-github-learning-resources
[github-flow]: https://docs.github.com/get-started/quickstart/github-flow
[github-signup]: https://github.com/signup/free
[github-fork]: https://docs.github.com/get-started/quickstart/fork-a-repo
[github-pr]: https://docs.github.com/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests
[github-pr-create]: https://docs.github.com/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork
[build]: docs/install.md#building-from-source
[vscode]: https://code.visualstudio.com/
[issues]: https://github.com/Azure/PSRule.Rules.Azure/issues
