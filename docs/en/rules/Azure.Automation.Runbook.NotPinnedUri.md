---
severity: Important
pillar: Security
category: Application security
resource: Automation Account
resourceType: Microsoft.Automation/automationAccounts/runbooks
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Automation.Runbook.NotPinnedUri/
---

# Use pinned script dependencies

## SYNOPSIS

Ensure automation runbooks use pinned script dependencies.

## DESCRIPTION

Azure Automation runbooks can reference external scripts via a `publishContentLink` URI.
When a runbook sources scripts from `https://raw.githubusercontent.com/`, the URI should reference a specific commit hash rather than a mutable reference such as a branch or tag name.

Unpinned references such as branch names or tags can be changed to point to different content at any time.
This introduces a supply chain risk where a malicious actor could modify the content at the URI after the runbook is created.

Using a pinned commit SHA ensures the runbook always executes the same, verified version of the script.

## RECOMMENDATION

Configure `publishContentLink.uri` to reference a specific commit SHA when sourcing scripts from `https://raw.githubusercontent.com/`.

For example, instead of:

```
https://raw.githubusercontent.com/Azure/PSRule.Rules.Azure/main/scripts/pipeline-deps.ps1
```

Use a pinned commit SHA:

```
https://raw.githubusercontent.com/Azure/PSRule.Rules.Azure/8dc395b739a8be00571d039c0af9df88d85c1e2a/scripts/pipeline-deps.ps1
```

## EXAMPLES

### Configure with Azure template

To deploy Automation Account runbooks that pass this rule:

- Set `properties.publishContentLink.uri` to a URL that uses a 40-character commit SHA as the ref.

For example:

```json
{
  "type": "Microsoft.Automation/automationAccounts/runbooks",
  "apiVersion": "2022-08-08",
  "name": "[format('{0}/{1}', parameters('accountName'), parameters('runbookName'))]",
  "location": "[parameters('location')]",
  "properties": {
    "runbookType": "PowerShell",
    "publishContentLink": {
      "uri": "https://raw.githubusercontent.com/Azure/PSRule.Rules.Azure/8dc395b739a8be00571d039c0af9df88d85c1e2a/scripts/pipeline-deps.ps1",
      "version": "1.0.0.0"
    }
  }
}
```

### Configure with Bicep

To deploy Automation Account runbooks that pass this rule:

- Set `properties.publishContentLink.uri` to a URL that uses a 40-character commit SHA as the ref.

For example:

```bicep
resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  name: '${accountName}/${runbookName}'
  location: location
  properties: {
    runbookType: 'PowerShell'
    publishContentLink: {
      uri: 'https://raw.githubusercontent.com/Azure/PSRule.Rules.Azure/8dc395b739a8be00571d039c0af9df88d85c1e2a/scripts/pipeline-deps.ps1'
      version: '1.0.0.0'
    }
  }
}
```

## LINKS

- [Manage runbooks in Azure Automation](https://learn.microsoft.com/azure/automation/manage-runbooks)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.automation/automationaccounts/runbooks)
