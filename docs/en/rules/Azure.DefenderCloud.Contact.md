---
severity: Important
pillar: Security
category: SE:12 Incident response
resource: Microsoft Defender for Cloud
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DefenderCloud.Contact/
ms-content-id: 18fcf75f-a5e6-4a34-baba-74bd49502cd7
---

# Set Security Center contact details

## SYNOPSIS

Microsoft Defender for Cloud email and phone contact details should be set.

## DESCRIPTION

Security contact details configured in Microsoft Defender for Cloud are used by Microsoft to notify you in response to certain security events.

## RECOMMENDATION

Consider configuring Microsoft Defender for Cloud email and phone contact details.

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINK

- [SE:12 Incident response](https://learn.microsoft.com/azure/well-architected/security/incident-response)
- [Quickstart: Configure email notifications for security alerts](https://learn.microsoft.com/azure/defender-for-cloud/configure-email-notifications)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.security/securitycontacts)
