---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.Updates/
ms-content-id: 8781c21b-4e6a-47fe-860d-d2191f0304ae
---

# Automatic updates are enabled

## SYNOPSIS

Ensure automatic updates are enabled at deployment.

## DESCRIPTION

Window virtual machines (VMs) have automatic updates turned on at deployment time by default.
The option can be enabled/ disabled at deployment time or updated for VM scale sets.

Enabling this option does not prevent automatic updates being disabled or reconfigured within the operating system after deployment.

## RECOMMENDATION

Enable automatic updates at deployment time, then reconfigure as required to meet patch management requirements.
