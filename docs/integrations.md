---
author: BernieWhite
discussion: false
---

# Integrations

## Integrates with PSRule for Azure

The following tools also take advantage of PSRule for Azure.

### Azure Governance Visualizer

[:octicons-book-24: Docs][1] · :octicons-milestone-24: v6_major_20220521_1

AzGovViz provides a convenient way to view your Azure governance and hierarchy.
Additionally you can view recommendations from PSRule as you navigate to each level in your hierarchy.

You can include PSRule recommendations in AzGovViz output by adding the `-DoPSRule` command-line switch.
This and more is included in the [documentation][1].

  [1]: https://aka.ms/AzGovViz

### Template Best Practice Analyzer (BPA)

[:octicons-book-24: Docs][2] · :octicons-milestone-24: v0.3.0

BPA scans Azure templates and Bicep code to ensure security and best practice checks are being followed before deployment.

By default, BPA will only include rules aligned to the Security Well-Architected Framework pillar.
To include rules from other pillars, use the `--include-non-security-rules` command-line switch.

  [2]: https://github.com/Azure/template-analyzer

### Microsoft Defender for DevOps

[:octicons-book-24: Docs][3] · :octicons-milestone-24: Public Preview

Microsoft Defender for DevOps (DfD) provides unified DevOps security management across multicloud and multiple-pipeline environments.

In this preview, DfD will include PSRule for Azure rules aligned to the Security Well-Architected Framework pillar.

  [3]: https://www.microsoft.com/security/business/cloud-security/microsoft-defender-devops
