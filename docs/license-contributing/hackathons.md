---
title: Past hackathons
author: BernieWhite
discussion: false
link_users: true
---

# Past hackathons

## Microsoft Global Hackathon 2022

Thanks to the team who made the following contributions during the hackathon:

- New features:
  - Mapping of Azure Security Benchmark v3 to security rules by @jagoodwin.
    [#1610](https://github.com/Azure/PSRule.Rules.Azure/issues/1610)
- New rules:
  - Azure Cache for Redis:
    - Check the number of firewall rules for caches by @jonathanruiz.
      [#544](https://github.com/Azure/PSRule.Rules.Azure/issues/544)
    - Check the number of IP addresses in firewall rules for caches by @jonathanruiz.
      [#544](https://github.com/Azure/PSRule.Rules.Azure/issues/544)
  - App Configuration:
    - Check identity-based authentication is used for configuration stores by @pazdedav.
      [#1691](https://github.com/Azure/PSRule.Rules.Azure/issues/1691)
  - Application Gateway WAF:
    - Check policy is enabled by @fbinotto.
      [#1470](https://github.com/Azure/PSRule.Rules.Azure/issues/1470)
    - Check policy uses prevention mode by @fbinotto.
      [#1470](https://github.com/Azure/PSRule.Rules.Azure/issues/1470)
    - Check policy uses managed rule sets by @fbinotto.
      [#1470](https://github.com/Azure/PSRule.Rules.Azure/issues/1470)
    - Check policy does not have any exclusions defined by @fbinotto.
      [#1470](https://github.com/Azure/PSRule.Rules.Azure/issues/1470)
  - Defender for Cloud:
    - Check Microsoft Defender for Cloud is enabled for Containers by @jdewisscher.
      [#1632](hhttps://github.com/Azure/PSRule.Rules.Azure/issues/1632)
    - Check Microsoft Defender for Cloud is enabled for Virtual Machines by @jdewisscher.
      [#1632](hhttps://github.com/Azure/PSRule.Rules.Azure/issues/1632)
    - Check Microsoft Defender for Cloud is enabled for SQL Servers by @jdewisscher.
      [#1632](hhttps://github.com/Azure/PSRule.Rules.Azure/issues/1632)
    - Check Microsoft Defender for Cloud is enabled for App Services by @jdewisscher.
      [#1632](hhttps://github.com/Azure/PSRule.Rules.Azure/issues/1632)
    - Check Microsoft Defender for Cloud is enabled for Storage Accounts by @jdewisscher.
      [#1632](hhttps://github.com/Azure/PSRule.Rules.Azure/issues/1632)
    - Check Microsoft Defender for Cloud is enabled for SQL Servers on machines by @jdewisscher.
      [#1632](hhttps://github.com/Azure/PSRule.Rules.Azure/issues/1632)
  - Front Door WAF:
    - Check policy is enabled by @fbinotto.
      [#1470](https://github.com/Azure/PSRule.Rules.Azure/issues/1470)
    - Check policy uses prevention mode by @fbinotto.
      [#1470](https://github.com/Azure/PSRule.Rules.Azure/issues/1470)
    - Check policy uses managed rule sets by @fbinotto.
      [#1470](https://github.com/Azure/PSRule.Rules.Azure/issues/1470)
    - Check policy does not have any exclusions defined by @fbinotto.
      [#1470](https://github.com/Azure/PSRule.Rules.Azure/issues/1470)
  - Network Security Group:
    - Check AKS managed NSGs don't contain custom rules by @ms-sambell.
      [#8](https://github.com/Azure/PSRule.Rules.Azure/issues/8)
  - Storage Account:
    - Check blob container soft delete is enabled by @pazdedav.
      [#1671](https://github.com/Azure/PSRule.Rules.Azure/issues/1671)
    - Check file share soft delete is enabled by @jonathanruiz.
      [#966](https://github.com/Azure/PSRule.Rules.Azure/issues/966)
- Updated rules:
  - Updated rules, tests and docs with Microsoft Defender for Cloud by @jonathanruiz.
    [#545](https://github.com/Azure/PSRule.Rules.Azure/issues/545)
    - The following rules have been renamed with aliases:
      - Renamed `Azure.SQL.ThreatDetection` to `Azure.SQL.DefenderCloud`.
      - Renamed `Azure.SecurityCenter.Contact` to `Azure.DefenderCloud.Contact`.
      - Renamed `Azure.SecurityCenter.Provisioning` to `Azure.DefenderCloud.Provisioning`.
    - If you are referencing the old names please consider updating to the new names.
  - Updated documentation examples for Front Door and Key Vault rules by @lluppesms.
    [#1667](https://github.com/Azure/PSRule.Rules.Azure/issues/1667)
- General improvements:
  - Updated NSG documentation with code snippets and links by @simone-bennett.
    [#1607](https://github.com/Azure/PSRule.Rules.Azure/issues/1607)
  - Updated Application Gateway documentation with code snippets by @ms-sambell.
    [#1608](https://github.com/Azure/PSRule.Rules.Azure/issues/1608)
  - Updated SQL firewall rules documentation by @ms-sambell.
    [#1569](https://github.com/Azure/PSRule.Rules.Azure/issues/1569)
  - Updated Container Apps documentation and rule to new resource type by @marie-schmidt.
    [#1672](https://github.com/Azure/PSRule.Rules.Azure/issues/1672)
  - Updated KeyVault and FrontDoor documentation with code snippets by @lluppesms.
    [#1667](https://github.com/Azure/PSRule.Rules.Azure/issues/1667)
  - Added tag and annotation metadata from policy for rules generation by @BernieWhite.
    [#1652](https://github.com/Azure/PSRule.Rules.Azure/issues/1652)
- Bug fixes:
  - Fixed continue processing policy assignments on error by @BernieWhite.
    [#1651](https://github.com/Azure/PSRule.Rules.Azure/issues/1651)
  - Fixed handling of runtime assessment data by @BernieWhite.
    [#1707](https://github.com/Azure/PSRule.Rules.Azure/issues/1707)
  - Fixed conversion of type conditions to pre-conditions by @BernieWhite.
    [#1708](https://github.com/Azure/PSRule.Rules.Azure/issues/1708)
