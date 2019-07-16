
## Unreleased

- Updated AKS version in `Azure.AKS.Version` to 1.13.7. [#83](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/83)
- Fix handling of empty DNS servers in `Azure.VirtualNetwork.LocalDNS`. [#84](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/84)
- Fix handling of no peering connections in `Azure.VirtualNetwork.LocalDNS`. [#89](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/89)

## v0.2.0

What's changed since v0.1.0:

- Fix rule `Azure.AKS.UseRBAC` returns null. [#60](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/60)
- Fix rule `Azure.Storage.SoftDelete` and `Azure.Storage.SecureTransferRequired` returns null. [#64](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/64)
- Fix collection of ASR vault configuration for cmdlet deprecation. [#63](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/63)
- Updated rules to use `Recommend` keyword instead of `Hint` alias. [#71](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/71)
- Added SQL firewall rule range check to determine an excessive number of permitted IP addresses. [#3](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/3) [#10](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/10) [#54](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/54)
  - The rules `Azure.SQL.FirewallIPRange`, `Azure.MySQL.FirewallIPRange` and `Azure.PostgreSQL.FirewallIPRange` were added to check SQL, MySQL and PostgreSQL.
- Added parameters to filter resource export by resource group and/ or tag. [#59](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/59)
  - Added `-ResourceGroupName` and `-Tag` parameters to `Export-AzRuleData` cmdlet.
- Added support for Application Gateway v2. [#75](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/75)
- Added VNET rule to check for local DNS. [#68](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/68)
- Added WAF hardening rules for Application Gateway. [#78](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/78)
  - Application Gateways use OWASP 3.x rules.
  - Application Gateways have WAF enabled.
  - Application Gateways have all OWASP rules enabled.

What's changed since pre-release v0.2.0-B190715:

- No additional changes.

## v0.2.0-B190715 (pre-release)

- Added support for Application Gateway v2. [#75](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/75)
- Added VNET rule to check for local DNS. [#68](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/68)
- Added WAF hardening rules for Application Gateway. [#78](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/78)
  - Application Gateways use OWASP 3.x rules.
  - Application Gateways have WAF enabled.
  - Application Gateways have all OWASP rules enabled.

## v0.2.0-B190706 (pre-release)

- Fix rule `Azure.AKS.UseRBAC` returns null. [#60](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/60)
- Fix rule `Azure.Storage.SoftDelete` and `Azure.Storage.SecureTransferRequired` returns null. [#64](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/64)
- Fix collection of ASR vault configuration for cmdlet deprecation. [#63](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/63)
- Added SQL firewall rule range check to determine an excessive number of permitted IP addresses. [#3](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/3) [#10](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/10) [#54](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/54)
  - The rules `Azure.SQL.FirewallIPRange`, `Azure.MySQL.FirewallIPRange` and `Azure.PostgreSQL.FirewallIPRange` were added to check SQL, MySQL and PostgreSQL.
- Updated rules to use `Recommend` keyword instead of `Hint` alias. [#71](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/71)
- Added parameters to filter resource export by resource group and/ or tag. [#59](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/59)
  - Added `-ResourceGroupName` and `-Tag` parameters to `Export-AzRuleData` cmdlet.

## v0.1.0

- Initial release.

What's changed since pre-release v0.1.0-B190624:

- No additional changes.

## v0.1.0-B190624 (pre-release)

- Added rule to check if allow access to Azure services enabled for MySQL. [#4](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/4)
- Added rule to count the number of database server firewall rules for MySQL. [#2](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/2)
- Added rule to check if allow access to Azure services enabled for PostgreSQL. [#50](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/50)
- Added rule to count the number of database server firewall rules for PostgreSQL. [#51](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/51)
- Added rule to check if SSL is enforced for PostgreSQL. [#49](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/49)

## v0.1.0-B190607 (pre-release)

- Added rule documentation. [#40](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/40)

## v0.1.0-B190569 (pre-release)

- Fix exported resource data overwritten. [#34](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/34)

## v0.1.0-B190562 (pre-release)

- Add units tests for `Export-AzRuleData` and update filters. [#28](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/28)
- `Export-AzRuleData` returns files generated by default. [#27](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/27)
- `Export-AzRuleData` passes through objects resource objects to the pipeline. [#25](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/25)
- **Breaking change** - `Export-AzRuleData` only exports data from current subscription context by default. [#24](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/24)
  - Data can be exported from all subscription contexts by using the `-All` switch, or specifying specific subscriptions with the `-Subscription` or `-Tenant` parameters.

## v0.1.0-B190543 (pre-release)

- Fix cannot find the type for custom attribute error. [#21](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/21)

## v0.1.0-B190536 (pre-release)

- Initial pre-release.
