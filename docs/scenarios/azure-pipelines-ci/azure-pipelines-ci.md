# Validate Azure resources from templates with Azure Pipelines

Azure Resource Manager (ARM) templates are a JSON-based file structure.
ARM templates are typically not static, they include parameters, functions and conditions.
Depending on the parameters provided to a template, resources may differ significantly.

Important resource properties that should be validated are often variables, parameters or deployed conditionally.
Under these circumstances, to correctly validate resources in a template, parameters must be resolved.

The following scenario shows how PSRule can be used to validate Azure resource templates within an Azure Pipeline.

This scenario covers the following:

- [Installing PSRule extension](#installing-psrule-extension)
- [Linking parameter files to templates](#linking-parameter-files-to-templates)
- [Creating a YAML pipeline](#creating-a-yaml-pipeline)
  - [Installing Azure rules](#installing-azure-rules)
  - [Exporting resource data for analysis](#exporting-resource-data-for-analysis)
  - [Validating exported resources](#validating-exported-resources)
- [Generating NUnit output](#generating-nunit-output)
- [Complete example](#complete-example)

## Installing PSRule extension

PSRule includes an extension that can be installed from the [Visual Studio Marketplace][extension].
Once installed, Azure Pipelines tasks are available to install PSRule modules and run analysis.

## Linking parameter files to templates

ARM template parameter files allows parameters for a deployment to be saved and checked into source control.
PSRule can automatically resolve ARM templates from parameter files by using a metadata link.

To link a parameter file to an ARM template add the `metadata.template` property within a parameter file.

For example:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "./azuredeploy.json"
    },
    "parameters": {
        "vnetName": {
            "value": "vnet-001"
        },
        "addressPrefix": {
            "value": [
                "10.1.0.0/24"
            ]
        }
    }
}
```

In the example parameter file `azuredeploy.parameters.json` is linked to the template `azuredeploy.json`.
The prefix of `./` indicates that the template file is in a relative path to the parameter file.
If `./` is not included, PSRule will look for the template relative to the working directory.

For example:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "templates/vnet-hub/v1/template.json"
    },
    "parameters": {
        "vnetName": {
            "value": "vnet-001"
        },
        "addressPrefix": {
            "value": [
                "10.1.0.0/24"
            ]
        }
    }
}
```

## Creating a YAML pipeline

Azure Pipelines supports defining pipelines in YAML.
PSRule uses a number of configurable task steps to install modules, export data and perform analysis.

### Installing Azure rules

To install the module containing Azure rules use the `ps-rule-install` YAML task.

```yaml
# Install PSRule.Rules.Azure from the PowerShell Gallery.
- task: ps-rule-install@2
  inputs:
    module: PSRule.Rules.Azure   # Install PSRule.Rules.Azure from the PowerShell Gallery.
```

### Exporting resource data for analysis

PSRule provides a pre-built cmdlets for finding template files within a path and exporting resource data.

- `Get-AzRuleTemplateLink` finds linked templates from parameter files.
By default, parameter files with the `*.parameters.json` extension are discovered.
Files are found recursively from the current working path.
- `Export-AzRuleTemplateData` exports resource data from template files.

To generate data for analysis use a PowerShell YAML task to export resource data from linked templates.

```yaml
# Export resource data from parameter files within the current working directory.
- powershell: Get-AzRuleTemplateLink | Export-AzRuleTemplateData -OutputPath out/templates/;
  displayName: 'Export template data'
```

If parameter files are located in a specific sub-directory the path can be updated as follows.

```yaml
# Export resource data from parameter files in the deployments/ sub-directory.
- powershell: Get-AzRuleTemplateLink ./deployments/ | Export-AzRuleTemplateData -OutputPath out/templates/;
  displayName: 'Export template data'
```

If parameter files do not use the file extension `.parameters.json` input path can be set.

```yaml
# Export resource data from parameter files ending in *.json instead of default *.parameters.json.
- powershell: Get-AzRuleTemplateLink -InputPath *.json | Export-AzRuleTemplateData -OutputPath out/templates/;
  displayName: 'Export template data'
```

In both cases, resource data for analysis is exported to `out/templates/`.

### Validating exported resources

To validate exported resources use the `ps-rule-assert` YAML task.
The following task uses previously exported resource data for analysis.

```yaml
# Run analysis from JSON files using the `PSRule.Rules.Azure` module and custom rules from `.ps-rule/`.
- task: ps-rule-assert@2
  inputs:
    inputType: inputPath
    inputPath: 'out/templates/*.json'        # Read exported resource data from 'out/templates/'.
    modules: 'PSRule.Rules.Azure'            # Analyze objects using the rules within the PSRule.Rules.Azure PowerShell module.
    # Optionally, also analyze objects using custom rules from '.ps-rule/'.
    source: '.ps-rule/'
    # Optionally, save results to an NUnit report.
    outputFormat: NUnit3
    outputPath: reports/ps-rule-resources.xml
```

In the example:

- Resource data is read from `out/templates/`.
- If custom rules are defined in the `.ps-rule/` these are also evaluated.
- Validation results are saved as an NUnit report.

## Generating NUnit output

NUnit is a popular unit test framework for .NET.
PSRule supports publishing validation results in the NUnit format.
With Azure DevOps, an NUnit report can be published using [Publish Test Results task][publish-test-results].

An example YAML snippet is included below:

```yaml
# Publish NUnit report as test results
- task: PublishTestResults@2
  displayName: 'Publish PSRule results'
  inputs:
    testRunTitle: 'PSRule'                          # The title to use for the test run.
    testRunner: NUnit                               # Import report using the NUnit format.
    testResultsFiles: 'reports/ps-rule-results.xml' # The previously saved NUnit report.
  condition: succeededOrFailed()                    # Run this task if previous steps succeeded of failed.
```

## Complete example

Putting each of these steps together.

### Azure DevOps Pipeline

```yaml
#
# PSRule with Azure Pipelines
#

trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

steps:

# Install PSRule.Rules.Azure from the PowerShell Gallery
- task: ps-rule-install@2
  inputs:
    module: PSRule.Rules.Azure   # Install PSRule.Rules.Azure from the PowerShell Gallery.

# Export resource data from parameter files within the current working directory.
- powershell: Get-AzRuleTemplateLink | Export-AzRuleTemplateData -OutputPath out/templates/;
  displayName: 'Export template data'

# Run analysis from JSON files using the `PSRule.Rules.Azure` module and custom rules from `.ps-rule/`.
- task: ps-rule-assert@2
  inputs:
    inputType: inputPath
    inputPath: 'out/templates/*.json'        # Read exported resource data from 'out/templates/'.
    modules: 'PSRule.Rules.Azure'            # Analyze objects using the rules within the PSRule.Rules.Azure PowerShell module.
    # Optionally, also analyze objects using custom rules from '.ps-rule/'.
    source: '.ps-rule/'
    # Optionally, save results to an NUnit report.
    outputFormat: NUnit3
    outputPath: reports/ps-rule-resources.xml

# Publish NUnit report as test results
- task: PublishTestResults@2
  displayName: 'Publish PSRule results'
  inputs:
    testRunTitle: 'PSRule'                          # The title to use for the test run.
    testRunner: NUnit                               # Import report using the NUnit format.
    testResultsFiles: 'reports/ps-rule-*.xml'       # Use previously saved NUnit reports.
    mergeTestResults: true                          # Merge multiple reports.
  condition: succeededOrFailed()                    # Run this task if previous steps succeeded of failed.

```

## More information

- [azure-pipelines.yaml](azure-pipelines.yaml) - An example Azure DevOps Pipeline.
- [azuredeploy.json](azuredeploy.json) - An example template file.
- [azuredeploy.parameters.json](azuredeploy.parameters.json) - An example parameters file.

[publish-test-results]: https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/test/publish-test-results
[extension]: https://marketplace.visualstudio.com/items?itemName=bewhite.ps-rule
