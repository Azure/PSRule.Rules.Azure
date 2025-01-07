# Quickstart: Use PSRule for Azure with Azure DevOps

This quickstart guide will help you set up PSRule for Azure in an Azure DevOps pipeline to validate Infrastructure as Code (IaC) templates, such as ARM or Bicep files. By the end, you will have a pipeline that installs and runs PSRule, validates IaC templates, and publishes validation results in Azure DevOps Test Reports.

## Prerequisites

1. **Azure DevOps account:** You need an Azure DevOps organization with an active project.
2. **IaC templates:** Ensure you have ARM or Bicep templates in your repository for validation.
3. **Agent pool:** An agent pool must be configured to execute pipelines. Use a self-hosted agent if needed.
4. **PowerShell Core:** Your build agent should have PowerShell Core installed (v7 or later).
5. **PSRule module:** The PSRule module will be installed during pipeline execution.

---

## Steps to Create the Pipeline

### Step 1: Add a Pipeline YAML File

Create a new file named `azure-pipeline.yml` in the root of your repository. This file defines the pipeline steps.

### Step 2: Define the Pipeline

Add the following content to your `azure-pipeline.yml` file:

```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: UsePythonVersion@0
  inputs:
    versionSpec: '3.x'

- task: PowerShell@2
  inputs:
    targetType: 'inline'
    script: |
      Install-Module -Name PSRule.Rules.Azure -Force -Scope CurrentUser
      pwsh -Command "Invoke-PSRule -InputPath './templates'"

- task: PublishTestResults@2
  inputs:
    testResultsFormat: 'JUnit'
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

---

## Reviewing Validation Results

1. Go to your Azure DevOps project.
2. Open the **Pipelines** section and view the pipeline run.
3. Look for validation output in the logs and **Test Results**.
4. Fix any reported issues in your IaC templates to pass validation.

---

For more information about PSRule for Azure, visit the [official documentation](https://azure.github.io/PSRule.Rules.Azure/).

