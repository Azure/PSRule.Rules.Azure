# Microsoft cloud security benchmark

Microsoft cloud security benchmark (MCSB) is a set of controls and recommendations that help improve the security of
workloads on Azure and your multi-cloud environment.
Controls from the MCSB are also mapped to industry frameworks, such as CIS, PCI-DSS, and NIST.

If you are new to MCSB or are looking for guidance on how to use it,
please see the [Introduction to the Microsoft cloud security benchmark][1].

  [1]: https://learn.microsoft.com/security/benchmark/azure/introduction

## Microsoft cloud security benchmark v1

Is the latest version of the MCSB.
Rules included within PSRule for Azure have been mapped to [v1][2] so that you are able to understand the impact of the rules.
This is particularly useful when you are looking to understand how to address a compliance requirement specific to your organization.

The following controls are included in the Microsoft cloud security benchmark v1:

- [Network security (NS)][3]
- [Identity Management (IM)][4]
- [Privileged Access (PA)][5]
- [Data Protection (DP)][6]
- [Asset Management (AM)][7]
- [Logging and Threat Detection (LT)][8]
- [Incident Response (IR)][9]
- [Posture and Vulnerability Management (PV)][10]
- [Endpoint Security (ES)][11]
- [Backup and Recovery (BR)][12]
- [DevOps Security (DS)][13]
- [Governance and Strategy (GS)][14]

  [2]: https://learn.microsoft.com/security/benchmark/azure/overview
  [3]: https://learn.microsoft.com/security/benchmark/azure/mcsb-network-security
  [4]: https://learn.microsoft.com/security/benchmark/azure/mcsb-identity-management
  [5]: https://learn.microsoft.com/security/benchmark/azure/mcsb-privileged-access
  [6]: https://learn.microsoft.com/security/benchmark/azure/mcsb-data-protection
  [7]: https://learn.microsoft.com/security/benchmark/azure/mcsb-asset-management
  [8]: https://learn.microsoft.com/security/benchmark/azure/mcsb-logging-threat-detection
  [9]: https://learn.microsoft.com/security/benchmark/azure/mcsb-incident-response
  [10]: https://learn.microsoft.com/security/benchmark/azure/mcsb-posture-vulnerability-management
  [11]: https://learn.microsoft.com/security/benchmark/azure/mcsb-endpoint-security
  [12]: https://learn.microsoft.com/security/benchmark/azure/mcsb-backup-recovery
  [13]: https://learn.microsoft.com/security/benchmark/azure/mcsb-devops-security
  [14]: https://learn.microsoft.com/security/benchmark/azure/mcsb-governance-strategy

### Using the MCSB v1 baseline

:octicons-beaker-24:{ .experimental } Experimental · :octicons-milestone-24: v1.25.0

To start using the MCSB v1 baseline with PSRule, [configure the baseline parameter][18] to use `Azure.MCSB.v1`.
View the [list of rules associated with the MCSB v1 baseline][15].

!!! Experimental "Experimental - [Learn more][19]"
    MCSB baselines are a work in progress and subject to change.
    We hope to add more rules to the baseline in the future.
    [Join or start a discussion][16] to let us know how we can improve this feature going forward.

!!! Note
    It's important to note that the MCSB v1 baseline is subset of rules from the Well-Architected Framework.
    Not all rules for the Well-Architected Framework are included in MCSB.
    Using the MCSB v1 baseline is useful to understand alignment with the MCSB and other industry frameworks / standards.
    For a complete set of rules for the Well-Architected Framework, consider using a [quarterly baseline][17].

  [15]: baselines/Azure.MCSB.v1.md
  [16]: https://github.com/Azure/PSRule.Rules.Azure/discussions
  [17]: ../working-with-baselines.md#quarterly-baselines
  [18]: ../working-with-baselines.md#using-baselines
  [19]: ../versioning.md#experimental-features

## Recommended content

- [Overview of Microsoft cloud security benchmark (v1)][2]
- [Using baselines][18]
