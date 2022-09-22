# Azure Security Benchmark

Azure Security Benchmark (ASB) is a set of controls and recommendations that help improve the security of workloads on Azure.
Controls from the ASB are also mapped to industry frameworks, such as CIS, PCI-DSS, and NIST.
If you are new to ASB or are looking for guidance on how to use it, please see the [Azure Security Benchmark introduction][1].

  [1]: https://docs.microsoft.com/security/benchmark/azure/introduction

## Azure Security Benchmark v3

Is the latest version of the ASB.
Rules included within PSRule for Azure have been mapped to [v3][2] so that you are able to understand the impact of the rules.
This is particularly useful when you are looking to understand how to address a compliance requirement specific to your organization.

The following controls are included in the Azure Security Benchmark v3:

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

  [2]: https://docs.microsoft.com/security/benchmark/azure/overview
  [3]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-network-security
  [4]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-identity-management
  [5]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-privileged-access
  [6]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-data-protection
  [7]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-asset-management
  [8]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-logging-threat-detection
  [9]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-incident-response
  [10]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-posture-vulnerability-management
  [11]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-endpoint-security
  [12]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-backup-recovery
  [13]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-devops-security
  [14]: https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-governance-strategy

<!-- ### Using the ASB v3 baseline with PSRule

:octicons-milestone-24: v1.nn.0

To start using the ASB v3 baseline with PSRule configure the baseline parameter to use `Azure.SecurityBenchmark.v3`.

!!! Note
    It's important to note that the ASB v3 baseline is reduced set of rules.
    Not all rules for the Well-Architected Framework are included in ASB v3. -->

## Links

- [Overview of Azure security controls (v3)][2]
