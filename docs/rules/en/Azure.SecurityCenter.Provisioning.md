---
severity: Important
pillar: Security
category: Security operations
resource: Security Center
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.SecurityCenter.Provisioning.md
ms-content-id: 966390bc-0358-43dd-8b5f-6b0ae2b16edd
---

# Enable Security Center auto-provisioning

## SYNOPSIS

Enable auto-provisioning on to improve Azure Security Center insights.

## DESCRIPTION

Select resources such as virtual machines (VMs) and VM scale sets require an agent to be installed to collect additional information from the operating system (OS).
This information is used to identify missing security updates and additional threats.

By turning auto-provisioning on, Security Center automatically deploys an Azure Monitor agent to VMs on a regular basis.

## RECOMMENDATION

Consider enabling auto-provisioning to improve Azure Security Center VM insights.

## LINKS

- [Data collection in Azure Security Center](https://docs.microsoft.com/en-us/azure/security-center/security-center-enable-data-collection)
