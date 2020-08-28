---
severity: Awareness
pillar: Operational Excellence
category: Deployment
resource: Virtual Machine
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.VM.NICAttached.md
---

# Attach NIC or clean up

## SYNOPSIS

Network interfaces (NICs) should be attached.

## DESCRIPTION

NICs are deployed as resources separate from virtual machines.
NICs that are not attached to a virtual machine perform no purpose.

## RECOMMENDATION

Consider cleaning up NICs that are not required to reduce management complexity.
Also consider using Resource Groups to help manage the lifecycle of related resources together.
