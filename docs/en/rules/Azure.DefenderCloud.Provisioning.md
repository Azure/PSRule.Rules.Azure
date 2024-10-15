---
severity: Important
pillar: Security
category: Security operations
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DefenderCloud.Provisioning/
ms-content-id: 966390bc-0358-43dd-8b5f-6b0ae2b16edd
---

# Enable Microsoft Defender for Cloud auto-provisioning

## SYNOPSIS

Enable auto-provisioning on to improve Microsoft Defender for Cloud insights.

## DESCRIPTION

Select resources such as virtual machines (VMs) and VM scale sets require an agent to be installed to collect additional information from the operating system (OS).
This information is used to identify missing security updates and additional threats.

By turning auto-provisioning on, Microsoft Defender for Cloud automatically deploys an Azure Monitor agent to VMs on a regular basis.

## RECOMMENDATION

Consider enabling auto-provisioning to improve Azure Microsoft Defender for Cloud VM insights.

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [Quickstart: Configure auto provisioning for agents and extensions from Microsoft Defender for Cloud](https://learn.microsoft.com/azure/defender-for-cloud/enable-data-collection)
