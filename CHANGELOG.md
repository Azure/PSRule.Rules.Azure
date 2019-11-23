# Change log

## Unreleased

- Improved template support of `Export-AzTemplateRuleData` cmdlet. [#145](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/145)
  - Added support for `deployment` function.
  - Fixed property copy loop.
- Fixed `Export-AzTemplateRuleData` does not return FileInfo objects. [#162](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/162)
- Fixed Automatically name outputs from `Export-AzTemplateRuleData`. [#163](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/163)

## v0.6.0-B1911027 (pre-release)

- Fixed processing of `Azure.Resource.UseTags` to exclude `*/providers/roleAssignments`. [#155](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/155)
  - Provider role assignments do not support tags.
- Fixed processing of `Azure.Resource.AllowedRegions`. [#156](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/156)
  - Exclude `*/providers/roleAssignments`, `Microsoft.Authorization/*` and `Microsoft.Consumption/*`.

## v0.6.0-B1911020 (pre-release)

- Fixed processing of `Azure.VirtualNetwork.NSGAssociated` for templates. [#150](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/150)
- Fixed processing of `Azure.VirtualNetwork.LateralTraversal` when `destinationPortRanges` is used. [#149](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/149)
- Improved template support of `Export-AzTemplateRuleData` cmdlet. [#145](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/145)
  - Added support for nested templates.
  - Added support for `array`, `createArray`, `coalesce`, `intersection`, `dataUri` and `dataUriToString` functions.

## v0.6.0-B1911011 (pre-release)

- Updated `Azure.AKS.Version` to 1.14.8. [#140](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/140)
- Updated rules to use type pre-conditions. [#144](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/144)
- **Experimental**: Added support for exporting rule data from templates. [#145](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/145)
  - Added `Export-AzTemplateRuleData` cmdlet to export templates. See cmdlet help for limitations.
  - Template and parameters are merged, resolving functions, copy loops and conditions.

## v0.5.0

What's changed since v0.4.0:

- New rules:
  - Virtual machines:
    - Added rule to verify Windows automatic updates are enabled. [#132](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/132)
    - Added rule to verify VM agent is automatically provisioned. [#131](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/131)
- Updated rules:
  - Azure Kubernetes Services:
    - Updated `Azure.AKS.Version` to 1.14.6. [#130](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/130)
- General improvements:
  - Shorten rule names for virtual machined to `Azure.VM.*` to improve output display. [#119](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/119)
    - **Breaking change**: Rules have been renamed from `Azure.VirtualMachine.*` to `Azure.VM.*`.

What's changed since pre-release v0.5.0-B1910004:

- No additional changes.

## v0.5.0-B1910004 (pre-release)

- Added rule to verify Windows automatic updates are enabled. [#132](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/132)
- Added rule to verify VM agent is automatically provisioned. [#131](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/131)
- Updated `Azure.AKS.Version` to 1.14.6. [#130](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/130)
- **Breaking change**: Renamed `Azure.VirtualMachine.*` rules to `Azure.VM.*`. [#119](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/119)

## v0.4.0

What's changed since v0.3.0:

- New rules:
  - Virtual machines:
    - Added rule to verify Azure Disk Encryption. [#122](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/122)
    - Added rule to check if public key is used for Linux. [#123](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/123)
  - Virtual networking:
    - Added rule to verify connectivity of VNET peers. [#120](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/120)
    - Added rule to check configuration of HTTP/ HTTPS load balancer probes. [#121](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/121)
- General improvements:
  - Removed dependency on Az.Storage module. [#105](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/105)
  - Added default baseline to module. [#126](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/126)

What's changed since pre-release v0.4.0-B190902:

- Added default baseline to module. [#126](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/126)

## v0.4.0-B190902 (pre-release)

- Added rule to verify connectivity of VNET peers. [#120](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/120)
- Added rule to check configuration of HTTP/ HTTPS load balancer probes. [#121](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/121)
- Added rule to verify Azure Disk Encryption. [#122](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/122)
- Added rule to check if public key is used for Linux. [#123](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/123)
- Removed dependency on Az.Storage module. [#105](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/105)

## v0.3.0

What's changed since v0.2.0:

- New rules:
  - App Services:
    - Enforce minimum TLS version for App Service. [#99](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/99)
  - Resource clean up:
    - Network security groups that are not associated. [#93](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/93)
    - Unattached network interfaces. [#92](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/92)
  - Role assignment:
    - Added subscription RBAC delegation rules. [#107](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/107)
      - Check for number of subscription owners.
      - Check for RBAC inheritance from management groups.
      - Check for user RBAC assignments.
      - Check for RBAC delegation on individual resources.
  - Virtual machines:
    - VMs should avoid using expired promo SKUs. [#87](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/87)
    - VMs should avoid using basic SKUs. [#69](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/69)
  - Virtual networking:
    - Added NSG rule to check for lateral traversal security rules. [#103](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/103)
    - Added rule to detect deny all inbound NSG rule. [#94](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/94)
- Updated rules:
  - App Services:
    - Updated App Service site rules to include slots. [#100](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/100)
    - `Azure.AppService.ARRAffinity` and `Azure.AppService.UseHTTPS` now run against slots.
  - Azure Kubernetes Services:
    - Updated `Azure.AKS.Version` to 1.14.5. [#109](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/109)
- Bug fixes:
  - Fix handling of empty DNS servers in `Azure.VirtualNetwork.LocalDNS`. [#84](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/84)
  - Fix handling of no peering connections in `Azure.VirtualNetwork.LocalDNS`. [#89](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/89)
  - Fix export of additional properties for `Microsoft.Sql/servers`. [#114](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/114)
  - Excluded global services from Azure.Resource.AllowedRegions. [#96](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/96)

What's changed since pre-release v0.3.0-B190807:

- Fix export of additional properties for `Microsoft.Sql/servers`. [#114](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/114)

## v0.3.0-B190807 (pre-release)

- Updated `Azure.AKS.Version` to 1.14.5. [#109](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/109)
- Added subscription RBAC delegation rules. [#107](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/107)
  - Check for number of subscription owners.
  - Check for RBAC inheritance from management groups.
  - Check for user RBAC assignments.
  - Check for RBAC delegation on individual resources.

## v0.3.0-B190723 (pre-release)

- Excluded global services from Azure.Resource.AllowedRegions. [#96](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/96)
- Enforce minimum TLS version for App Service. [#99](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/99)
- Updated App Service site rules to include slots. [#100](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/100)
  - `Azure.AppService.ARRAffinity` and `Azure.AppService.UseHTTPS` now run against slots.
- Added rule to detect deny all inbound NSG rule. [#94](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/94)
- Added unused resource rules.
  - Network security groups that are not associated. [#93](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/93)
  - Unattached network interfaces. [#92](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/92)
- Added NSG rule to check for lateral traversal security rules. [#103](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/103)

## v0.3.0-B190710 (pre-release)

- Fix handling of empty DNS servers in `Azure.VirtualNetwork.LocalDNS`. [#84](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/84)
- Fix handling of no peering connections in `Azure.VirtualNetwork.LocalDNS`. [#89](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/89)
- Updated AKS version in `Azure.AKS.Version` to 1.13.7. [#83](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/83)
- Added VM SKU rules:
  - VMs should avoid using expired promo SKUs. [#87](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/87)
  - VMs should avoid using basic SKUs. [#69](https://github.com/BernieWhite/PSRule.Rules.Azure/issues/69)

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
