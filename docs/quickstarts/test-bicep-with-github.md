---
description: Learn how to setup your GitHub repository to automatically test Bicep code (deployments) using Bicep parameter files and PSRule for Azure.
author: BernieWhite
---

# Test a Bicep deployment with GitHub Actions

Azure Bicep supports using a parameter file to deploy a module to Azure.
In this quickstart, you will learn how to set up your GitHub repository to automatically test deployments
that use Bicep parameter files (`.bicepparam`).

Once set up, GitHub Actions will run PSRule for Azure to test your Bicep code during pull requests and pushes.
You can configure the GitHub Actions workflow triggers to run on additional branches or events.

Testing your Bicep code using parameter files is a great way to ensure your code produces Azure resources
that meet the security and compliance requirements of your organization.

## Before you begin

This quickstart assumes you have already:

1. Installed Git locally and created a GitHub account.
   For more information, see [Setup Git][1] and [Signing up for a new GitHub account][2].
2. Created a GitHub repository and cloned it locally.
   For more information, see [Create a repo][3] and [Clone a repo][4].
3. Installed an editor or IDE locally to edit your repository files.
   For more information, see [Visual Studio Code][5].

  [1]: https://docs.github.com/get-started/quickstart/set-up-git
  [2]: https://docs.github.com/get-started/signing-up-for-github/signing-up-for-a-new-github-account
  [3]: https://docs.github.com/get-started/quickstart/create-a-repo
  [4]: https://docs.github.com/repositories/creating-and-managing-repositories/cloning-a-repository
  [5]: https://code.visualstudio.com/

## Add a sample Bicep deployment

If you don't already have a Bicep deployment in your repository, add a sample deployment.

1. In the root of your repository, create a new folder called `deployments`.
2. In the `deployments` folder, create a new file called `dev.bicepparam`.
3. In the `deployments` folder, create a new file called `main.bicep`.

??? Example "Example parameter file"

    ```bicep title="deployments/dev.bicepparam"
    using 'main.bicep'

    param environment = 'dev'
    param name = 'kv-example-001'
    param defaultAction = 'Deny'
    param workspaceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/rg-test/providers/microsoft.operationalinsights/workspaces/workspace-001'
    ```

??? Example "Example deployment module"

    ```bicep title="deployments/main.bicep"
    targetScope = 'resourceGroup'

    param name string
    param location string = resourceGroup().location

    @allowed([
      'Allow'
      'Deny'
    ])
    param defaultAction string = 'Deny'
    param environment string
    param workspaceId string = ''

    resource vault 'Microsoft.KeyVault/vaults@2023-02-01' = {
      name: name
      location: location
      properties: {
        sku: {
          family: 'A'
          name: 'standard'
        }
        tenantId: tenant().tenantId
        enableSoftDelete: true
        enablePurgeProtection: true
        enableRbacAuthorization: true
        networkAcls: {
          defaultAction: defaultAction
        }
      }
      tags: {
        env: environment
      }
    }

    @sys.description('Configure auditing for Key Vault.')
    resource logs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(workspaceId)) {
      name: 'service'
      scope: vault
      properties: {
        workspaceId: workspaceId
        logs: [
          {
            category: 'AuditEvent'
            enabled: true
          }
        ]
      }
    }
    ```

You can also find a copy of these files in the [quickstart sample repository][6].

  [6]: https://github.com/Azure/PSRule.Rules.Azure-quickstart/tree/main/deployments/contoso/landing-zones/subscription-1/rg-app-001

## Create an options file

PSRule can be configured using a default YAML options file called `ps-rule.yaml`.
Many of configuration options you are likely to want to use can be set using this file.
Options in this file will automatically be detected by other PSRule commands and tools.

1. Create a new branch in your repository for your changes.
   For more information, see [Creating a branch][7].
2. In the root of your repository, create a new file called `ps-rule.yaml`.
3. Update the file with the following contents and save.

```yaml title="ps-rule.yaml"
#
# PSRule configuration
#

# Please see the documentation for all configuration options:
# https://aka.ms/ps-rule-azure/options

# Require a minimum version of PSRule for Azure.
requires:
  PSRule.Rules.Azure: '>=1.34.0' # (1)

# Automatically use rules for Azure.
include:
  module:
  - PSRule.Rules.Azure # (2)

# Ignore all files except .bicepparam files.
input:
  pathIgnore:
  - '**' # (3)
  - '!**/*.bicepparam' # (4)
```

<div class="result" markdown>
1.  Set the minimum required version of PSRule for Azure to use.
    This does not install the required version, but will fail if the version is not available.
    Across a team and CI/CD pipeline, this can help ensure a consistent version of PSRule is used.
2.  Automatically use the rules in PSRule for Azure for each run.
3.  Ignore all files by default.
    PSRule will not try to analyze ignored files.
4.  Add an exception for `.bicepparam` files.

</div>

  [7]: https://code.visualstudio.com/docs/sourcecontrol/overview#_branches-and-tags

## Create a workflow

GitHub Actions are configured using a YAML file called a workflow.
A workflow is made up of one or more jobs and steps.

1. In the root of your repository, create a new folder called `.github/workflows`.
2. In the `.github/workflows` folder, create a new file called `analysis.yaml`.
3. Update the file with the following contents and save.

```yaml title="GitHub Actions workflow"
#
# Analyze repository with PSRule
#

# For PSRule documentation see:
# https://aka.ms/ps-rule
# https://aka.ms/ps-rule-azure

# For action details see:
# https://aka.ms/ps-rule-action

name: Analyze repository

# Run analysis for main or PRs against main
on:
  push:
    branches:
    - main
  pull_request:
    branches:
    - main

jobs:
  analyze:
    name: Analyze repository
    runs-on: ubuntu-latest
    steps:

    - name: Checkout
      uses: actions/checkout@v4

    - name: Run PSRule analysis
      uses: microsoft/ps-rule@v2.9.0 # (1)
      with:
        modules: PSRule.Rules.Azure # (2)
```

<div class="result" markdown>
1.  Reference the PSRule action.
    You can find the latest version of the action on the [GitHub Marketplace][14].
2.  Automatically download and use PSRule for Azure during analysis.

</div>

  [14]: https://github.com/marketplace/actions/psrule

## Commit and push changes

1. Commit and push the changes to your repository.
   For more information, see [Committing changes to your project][8].
2. Create a pull request to merge the changes into the `main` branch in GitHub.
   For more information, see [Creating a pull request][9].
3. Navigate to the Actions tab in your repository to check the status of the workflow.

  [8]: https://code.visualstudio.com/docs/sourcecontrol/overview#_commit
  [9]: https://docs.github.com/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request

## Related content

- [Testing Bicep modules][10]
- [Restoring modules from a private registry][11]
- [Suppression and excluding rules][12]
- [Enforcing custom tags][13]

  [10]: ../using-bicep.md#testing-bicep-modules
  [11]: ../using-bicep.md#restoring-modules-from-a-private-registry
  [12]: ../concepts/suppression.md
  [13]: ../customization/enforce-custom-tags.md
