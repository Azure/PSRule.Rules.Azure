---
description: Learn how to create a custom rule to validate the file path of code artifacts.
author: BernieWhite
---

# Enforcing code ownership

With PSRule, you can layer on custom rules with to implement organization specific requirements.
These custom rules work side-by-side with PSRule for Azure.

Pull requests are a key concept within common Git workflows used with DevOps to enforce peer review.
To support peer review across a team tools such as GitHub and Azure DevOps provide code ownership.
Code ownership, allows mix discipline teams to direct peer reviews based the path of a changed file.

For sensitive changes such as firewall or policy exemptions, peer reviews may form a security control.
In these cases, it may be important that specific paths are used for Infrastructure as Code artifacts.

!!! Info
    Code ownership is implemented through [CODEOWNERS][1] in GitHub and [required reviewers][2] in Azure Repos.

!!! Abstract
    The following scenario shows how to create a custom rule to validate the file path of code artifacts.
    The scenario walks you through the process so that you can apply the same concepts for similar requirements.

  [1]: https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners
  [2]: https://learn.microsoft.com/azure/devops/repos/git/branch-policies#automatically-include-code-reviewers

## Creating a new rule

Within the `.ps-rule` sub-directory create a new file called `Org.Azure.Rule.ps1`.
Use the following snippet to populate the rule file:

```powershell
# Synopsis: Policy exemptions must be stored under designated paths for review.
Rule 'Org.Azure.Policy.Path' -Type 'Microsoft.Authorization/policyExemptions' {
    $Assert.WithinPath($PSRule.Source['Parameter'], '.', @(
        'deployments/policy/'
    ));
}
```

Some key points to call out with the rule snippet include:

- The name of the rule is `Org.Azure.Policy.Path`.
  Each rule name must be unique.
- The rule applies to resources with the type of `Microsoft.Authorization/policyExemptions`.
  i.e. Policy exemptions.
- The synopsis comment above the rule is read and used as the default recommendation if the rule fails.
  The rule recommendation appears in output and is intended as an instruction to remediate the failure.
- The assertion `$Assert.WithinPath` ensures the specifies path is within the `deployments/policy/` sub-directory.
- The automatic variable `$PSRule.Source` exposes the source path for the resource.
  PSRule for Azure exposes a `Template` and `Parameter` source for resources originating from a template.

!!! Tip
    For recommendations on naming and storing rules see [storing custom rules][3].

  [3]: storing-custom-rules.md

## Binding type

Rules packaged within PSRule for Azure will automatically detect Policy Exemptions by their type properties.
Standalone rules will get their type binding configuration from `ps-rule.yaml` instead.

To configure type binding:

- Create/ update the `ps-rule.yaml` file within the root of the repository.
- Add the following configuration snippet.

```yaml
# Configure binding options
binding:
  targetType:
  - 'resourceType'
  - 'type'
```

Some key points to call out include:

- Configuring the binding for `targetType` allows rules to use the `-Type` parameter.
Our custom rule uses `-Type 'Microsoft.Authorization/policyExemptions'`.
- The binding configuration will use the `resourceType` property if it exists,
alternative it will use `type`.
If neither property exists, PSRule will use the object type.

## Testing locally

To test the custom rule within Visual Studio Code, see [How to install PSRule for Azure][4].
Alternatively you can test the rule manually by running the following from a PowerShell terminal.

```powershell
Assert-PSRule -Path '.ps-rule/' -Module 'PSRule.Rules.Azure' -InputPath . -Format File
```

  [4]: ../install.md#with-visual-studio-code

## Sample code

Grab the full sample code for each of these files from:

- [Org.Azure.Rule.ps1](https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/customization/enforce-codeowners/.ps-rule/Org.Azure.Rule.ps1)
- [ps-rule.yaml](https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/customization/enforce-codeowners/ps-rule.yaml)
- [policy-exemption.parameters.json](https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/customization/enforce-codeowners/deployments/policy/policy-exemptions.parameters.json)
- [template.json](https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/customization/enforce-codeowners/templates/policy-exemption/v1/template.json)
