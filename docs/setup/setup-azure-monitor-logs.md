---
author: BernieWhite
---

# Setup Azure Monitor logs

When analyzing Azure resources, you may want to capture the results of each analysis run.
Azure Monitor provides a central storage location for log data through [Log Analytics][1] workspaces.
Centrally storing PSRule results enables the following scenarios:

- **Auditing and reporting** &mdash; Report on analysis pass or failures.
  - Use Azure Monitor [workbooks][4] or [custom queries][3] to perform analysis and display results.
  - Perform security analysis within [Microsoft Azure Sentinel][2] your a scalable, cloud-native SIEM.
    Alternatively, export log data from Log Analytics for ingestion into a third-party SIEM.
- **Send notifications using alerts** &mdash; Trigger [alerts][5] to send notifications.
- **Integration with other workflows** &mdash; Configure alerts and action groups to [trigger integration][6].

!!! Abstract
    This topic covers setting up PSRule to log rule results into a [Log Analytics][1] workspace.

  [1]: https://docs.microsoft.com/azure/azure-monitor/logs/log-analytics-overview
  [2]: https://docs.microsoft.com/azure/sentinel/overview
  [3]: https://docs.microsoft.com/azure/azure-monitor/logs/queries
  [4]: https://docs.microsoft.com/azure/azure-monitor/visualize/workbooks-overview
  [5]: https://docs.microsoft.com/azure/azure-monitor/alerts/alerts-log
  [6]: https://docs.microsoft.com/azure/azure-monitor/alerts/alerts-common-schema-integrations

## Logging into a Log Analytics workspace

Logging of PSRule results into a workspace is done using the _PSRule for Azure Monitor_ module.
PSRule for Azure Monitor extends the PSRule pipeline to import results into the specified workspace.

Once configured, PSRule will log results into the `PSRule_CL` custom log table of the chosen workspace.

!!! Info
    Integration between PSRule and Azure Monitor is done by means of a convention.
    Conventions extend the pipeline to be able to upload results after rules have run.

### Setting environment variables

PSRule for Azure Monitor requires a Log Analytics workspace to import results into.
To configure the workspace to import results to the following environment variables must be set.

- `PSRULE_CONFIGURATION_MONITOR_WORKSPACE_ID` - The unique ID (GUID) for the workspace to import results.
- `PSRULE_CONFIGURATION_MONITOR_WORKSPACE_KEY` - Either the primary or secondary key of the workspace.

How to set these environment variables is covered in the next section for GitHub Actions and Azure Pipelines.

!!! Tip
    Both the workspace ID and keys can be found under the _Agents management_ settings of the workspace.

## Configuring your pipeline

The convention that imports PSRule analysis results is not executed by default.
To enable, reference the `Monitor.LogAnalytics.Import` convention in your analysis pipeline.

### With GitHub Actions

[:octicons-workflow-24: GitHub Action][7]

Import analysis results into Azure Monitor with GitHub Actions by:

- Using the `PSRule.Monitor` module.
- Referencing the `Monitor.LogAnalytics.Import` convention.
- Configure secrets for `MONITOR_WORKSPACE_ID` and `MONITOR_WORKSPACE_KEY`.

=== "Stable"

    Install the latest stable module versions.

    ```yaml
    - name: Analyze Azure template files
      uses: microsoft/ps-rule@v2.9.0
      with:
        modules: PSRule.Rules.Azure,PSRule.Monitor
        conventions: Monitor.LogAnalytics.Import
      env:
        # Define environment variables using GitHub encrypted secrets
        PSRULE_CONFIGURATION_MONITOR_WORKSPACE_ID: ${{ secrets.MONITOR_WORKSPACE_ID }}
        PSRULE_CONFIGURATION_MONITOR_WORKSPACE_KEY: ${{ secrets.MONITOR_WORKSPACE_KEY }}
    ```

=== "Pre-release"

    Install the latest stable or pre-release module versions.

    ```yaml
    - name: Analyze Azure template files
      uses: microsoft/ps-rule@v2.9.0
      with:
        modules: PSRule.Rules.Azure,PSRule.Monitor
        conventions: Monitor.LogAnalytics.Import
        prerelease: true
      env:
        # Define environment variables using GitHub encrypted secrets
        PSRULE_CONFIGURATION_MONITOR_WORKSPACE_ID: ${{ secrets.MONITOR_WORKSPACE_ID }}
        PSRULE_CONFIGURATION_MONITOR_WORKSPACE_KEY: ${{ secrets.MONITOR_WORKSPACE_KEY }}
    ```

!!! Important
    Environment variables can be configured in the workflow or from a secret.
    To keep `MONITOR_WORKSPACE_KEY` secure, use an [encrypted secret][8].

  [7]: https://github.com/marketplace/actions/psrule
  [8]: https://docs.github.com/actions/reference/encrypted-secrets

### With Azure Pipelines

[:octicons-workflow-24: Extension][9]

Import analysis results into Azure Monitor with Azure Pipelines by:

- Installing the PSRule [extension][9], then using the `ps-rule-assert` task in pipeline steps.
- Using the `PSRule.Monitor` module.
- Referencing the `Monitor.LogAnalytics.Import` convention.
- Configure variables for `MONITORWORKSPACEID` and `MONITORWORKSPACEKEY`.

=== "Stable"

    Install the latest stable module versions.

    ```yaml
    - task: ps-rule-assert@2
      displayName: Analyze Azure template files
      inputs:
        modules: PSRule.Rules.Azure,PSRule.Monitor
        conventions: Monitor.LogAnalytics.Import
      env:
        # Define environment variables within Azure Pipelines
        PSRULE_CONFIGURATION_MONITOR_WORKSPACE_ID: $(MONITORWORKSPACEID)
        PSRULE_CONFIGURATION_MONITOR_WORKSPACE_KEY: $(MONITORWORKSPACEKEY)
    ```

=== "Pre-release"

    Install the latest stable or pre-release module versions.

    ```yaml
    - task: ps-rule-install@2
      displayName: Install PSRule for Azure (pre-release)
      inputs:
        module: PSRule.Rules.Azure
        prerelease: true

    - task: ps-rule-install@2
      displayName: Install PSRule for Azure Monitor (pre-release)
      inputs:
        module: PSRule.Monitor
        prerelease: true

    - task: ps-rule-assert@2
      displayName: Analyze Azure template files
      inputs:
        modules: PSRule.Rules.Azure,PSRule.Monitor
        conventions: Monitor.LogAnalytics.Import
      env:
        # Define environment variables within Azure Pipelines
        PSRULE_CONFIGURATION_MONITOR_WORKSPACE_ID: $(MONITORWORKSPACEID)
        PSRULE_CONFIGURATION_MONITOR_WORKSPACE_KEY: $(MONITORWORKSPACEKEY)
    ```

!!! Important
    Variables can be configured in YAML, on the pipeline, or referenced from a defined variable group.
    To keep `MONITORWORKSPACEKEY` secure, use a [variable group][10] linked to an Azure Key Vault.

  [9]: https://marketplace.visualstudio.com/items?itemName=bewhite.ps-rule
  [10]: https://docs.microsoft.com/azure/devops/pipelines/library/variable-groups

## Samples

Continue reading for some sample resources you can try once this integration is setup Azure Monitor integration.

### Log Analytics Queries

#### Results with annotations

```kql title="Kusto"
// Show extended info
PSRule_CL
| where TimeGenerated > ago(30d)
| extend Pillar = tostring(parse_json(Annotations_s).pillar)
| extend Link = tostring(parse_json(Annotations_s).["online version"])
```

#### Summarize results by run

```kql title="Kusto"
// Group by run
PSRule_CL
| where TimeGenerated > ago(30d)
| summarize Pass=countif(Outcome_s == "Pass"), Fail=countif(Outcome_s  == "Fail") by RunId_s
```

*[SIEM]: security information event management

#### Querying The Data

Once the results have been published to the Log Analytics workspace, they can be queried by executing
results against the `PSRule_CL` table (under Custom Logs). For more information on how to write Log
Analytics querys, review the [Log Analytics tutortial][11].

  [11]: https://docs.microsoft.com/azure/azure-monitor/logs/log-analytics-tutorial

### Workbook

[:octicons-code-square-24: Workbook][13]

A [sample Azure Monitor Workbook][13] is available in the PSRule for Azure GitHub repository.
This workbook can be imported directly into Azure Monitor and used as a foundation to build from.
Review the [Workbook creation tutorial][12] for instructions on how to work with the sample Workbook.

  [12]: https://docs.microsoft.com/azure/azure-monitor/visualize/workbooks-create-workbook
  [13]: https://github.com/Azure/PSRule.Rules.Azure/blob/main/docs/setup/workbook.json
