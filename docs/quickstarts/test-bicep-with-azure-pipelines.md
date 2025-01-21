# Quickstart: Use PSRule for Azure with Azure DevOps

This quickstart guide will help you set up PSRule for Azure in an Azure DevOps pipeline to validate Infrastructure as Code (IaC) templates, such as ARM or Bicep files.
By the end, you will have a pipeline that installs and runs PSRule, validates IaC templates, and publishes validation results in Azure DevOps Test Reports.

## Before you begin

1. **Azure DevOps account:** You need an Azure DevOps organization with an active project.
2. **IaC templates:** Ensure you have ARM or Bicep templates in your repository for validation.
3. **Agent pool:** An agent pool must be configured to execute pipelines. Use a self-hosted agent if needed.
4. **PowerShell Core:** Your build agent should have PowerShell Core installed (v7 or later).
5. **PSRule module:** The PSRule module will be installed during pipeline execution.

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
  PSRule.Rules.Azure: '>=1.40.0' # (1)

# Automatically use rules for Azure.
include:
  module:
  - PSRule.Rules.Azure # (2)

# Ignore all files except .bicepparam files.
input:
  pathIgnore:
  - '**' # (3)
  - '!**/*.bicepparam' # (4)

configuration:
  # Enable expansion of .bicepparam files.
  AZURE_BICEP_PARAMS_FILE_EXPANSION: true # (5)
```

<div class="result" markdown>
1.  Set the minimum required version of PSRule for Azure to use.
    This does not install the required version, but will fail if the version is not available.
    Across a team and CI/CD pipeline, this can help ensure a consistent version of PSRule is used.
2.  Automatically use the rules in PSRule for Azure for each run.
3.  Ignore all files by default.
    PSRule will not try to analyze ignored files.
4.  Add an exception for `.bicepparam` files.
5.  Enable expansion of `.bicepparam` files so that each Azure resource is tested.

</div>

  [7]: https://code.visualstudio.com/docs/sourcecontrol/overview#_branches-and-tags

## Steps to Create the Pipeline

### Step 1: Add a Pipeline YAML File

Create a new file named `azure-pipeline.yml` in the root of your repository. This file defines the pipeline steps.

### Step 2: Define the Pipeline

Add the following content to your `azure-pipeline.yml` file:

```yaml title="Azure Pipelines YAML"
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: UsePythonVersion@0
  inputs:
    versionSpec: '3.x'

- task: PSRule@1
  inputs:
    module: 'PSRule.Rules.Azure'
    inputPath: './templates'
    options: './ps-rule.yaml'

- task: PowerShell@2
  inputs:
    targetType: 'inline'
    script: |
      Install-Module -Name PSRule.Rules.Azure -Force -Scope CurrentUser
      pwsh -Command "Assert-PSRule -InputPath './templates' -Option './ps-rule.yaml'"

- task: PublishTestResults@2
  inputs:
    testResultsFormat: 'NUnit3'
    testResultsFiles: '**/psrule-results.xml'
```

### Step 3: Commit and Push

1. Commit your changes to the repository:
   ```bash
   git add azure-pipeline.yml
   git commit -m "Add Azure DevOps pipeline for PSRule validation"
   git push origin main
   ```

2. The pipeline will automatically trigger and validate your templates.

## Reviewing Validation Results

1. Go to your Azure DevOps project.
2. Open the **Pipelines** section and view the pipeline run.
3. Look for validation output in the logs and **Test Results**.
4. Fix any reported issues in your IaC templates to pass validation.
