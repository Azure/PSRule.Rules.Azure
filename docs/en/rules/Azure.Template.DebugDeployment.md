---
severity: Awareness
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.DebugDeployment/
---

# Disable debugging of nested deployments

## SYNOPSIS

Use default deployment detail level for nested deployments.

## DESCRIPTION

When creating Azure template, nested deployments can be created with debugging settings enabled.
Deployment debugging detail is intended for troubleshooting deployments during development.
Debugging settings may log sensitive values.
Use caution when using this setting to debug of nested deployments.

To reduce nested deployment detail,
remove or configure the `properties.debugSetting.detailLevel` property to `none` for nested deployments.

## RECOMMENDATION

Consider disabling debugging of nested deployments before release.

## LINKS

- [Troubleshoot deployment errors](https://learn.microsoft.com/azure/azure-resource-manager/templates/common-deployment-errors#nested-template)
- [DebugSetting](https://learn.microsoft.com/azure/templates/microsoft.resources/deployments#DebugSetting)
- [Release deployment](https://learn.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
