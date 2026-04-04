---
reviewed: 2026-04-04
severity: Important
pillar: Security
category: SE:02 Secured development lifecycle
resource: Automation Account
resourceType: Microsoft.Automation/automationAccounts/runbooks,Microsoft.Automation/automationAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Automation.RunbookPinned/
---

# Automation runbook is not pinned

## SYNOPSIS

Runbooks that use external scripts from an unpinned URL may be modified to execute malicious code.

## DESCRIPTION

When an Azure Automation runbook uses an external script from a URL, the script content could change between runs.
If the URL is not pinned to a specific commit, a supply chain attack could modify the script and execute malicious code with elevated privileges.

When using scripts from GitHub, a URL should be pinned to a specific commit hash rather than a branch or tag.
A branch or tag can be modified to point to a different commit, allowing a malicious actor to modify the script.
A commit hash is unique and cannot be changed without creating a new commit.

## RECOMMENDATION

Consider updating the runbook to use a URL pinned to a specific commit hash.

## EXAMPLES

### Configure with Bicep

To deploy automation runbooks that pass this rule:

- Set the `properties.publishContentLink.uri` property to a URL that is pinned to a specific commit hash.
  - For GitHub hosted scripts, use `https://raw.githubusercontent.com/{owner}/{repo}/{commit-sha}/{path}`.

For example:

```bicep
resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2023-11-01' = {
  parent: automationAccount
  name: 'runbook-001'
  location: location
  properties: {
    runbookType: 'PowerShell'
    publishContentLink: {
      uri: 'https://raw.githubusercontent.com/Azure/PSRule.Rules.Azure/8dc395b739a8be00571d039c0af9df88d85c1e2a/scripts/pipeline-deps.ps1'
    }
  }
}
```

### Configure with Azure template

To deploy automation runbooks that pass this rule:

- Set the `properties.publishContentLink.uri` property to a URL that is pinned to a specific commit hash.
  - For GitHub hosted scripts, use `https://raw.githubusercontent.com/{owner}/{repo}/{commit-sha}/{path}`.

For example:

```json
{
  "type": "Microsoft.Automation/automationAccounts/runbooks",
  "apiVersion": "2023-11-01",
  "name": "[format('{0}/{1}', parameters('automationAccountName'), 'runbook-001')]",
  "location": "[parameters('location')]",
  "properties": {
    "runbookType": "PowerShell",
    "publishContentLink": {
      "uri": "https://raw.githubusercontent.com/Azure/PSRule.Rules.Azure/8dc395b739a8be00571d039c0af9df88d85c1e2a/scripts/pipeline-deps.ps1"
    }
  }
}
```

## NOTES

This rule currently only evaluates content hosted on GitHub, with URLs starting with `https://raw.githubusercontent.com/`.
Please log a feature request on if you would like to see support for other hosting providers or URL formats.

## LINKS

- [SE:02 Secured development lifecycle](https://learn.microsoft.com/azure/well-architected/security/secure-development-lifecycle)
- [Security: Level 1](https://learn.microsoft.com/azure/well-architected/security/maturity-model?tabs=level1)
- [Manage runbooks in Azure Automation](https://learn.microsoft.com/azure/automation/manage-runbooks)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.automation/automationaccounts/runbooks)
