# Change log

**Important notes**:

- Issue #741: `Could not load file or assembly YamlDotNet`.
See [troubleshooting guide] for a workaround to this issue.

## Unreleased

What's changed since v1.9.1:

- Engineering:
  - Bump PSRule dependency to v1.9.0. [#1081](https://github.com/Azure/PSRule.Rules.Azure/issues/1081)
  - Bump Microsoft.CodeAnalysis.NetAnalyzers to v6.0.0. [#1080](https://github.com/Azure/PSRule.Rules.Azure/pull/1080)

## v1.9.1

What's changed since v1.9.0:

- Bug fixes:
  - Fixed can not index into resource group tags. [#1066](https://github.com/Azure/PSRule.Rules.Azure/issues/1066)
  - Fixed `Azure.VM.ASMinMembers` for template deployments. [#1064](https://github.com/Azure/PSRule.Rules.Azure/issues/1064)
  - Fixed zones property not found on public IP resource. [#1070](https://github.com/Azure/PSRule.Rules.Azure/issues/1070)

## v1.9.0

What's changed since v1.8.1:

- New rules:
  - API Management Service:
    - Check API management services are using availability zones when available. [#1017](https://github.com/Azure/PSRule.Rules.Azure/issues/1017)
  - Public IP Address:
    - Check Public IP addresses are configured with zone-redundancy. [#958](https://github.com/Azure/PSRule.Rules.Azure/issues/958)
    - Check Public IP addresses are using Standard SKU. [#979](https://github.com/Azure/PSRule.Rules.Azure/issues/979)
  - User Assigned Managed Identity:
    - Check identities meet naming requirements. [#1021](https://github.com/Azure/PSRule.Rules.Azure/issues/1021)
  - Virtual Network Gateway:
    - Check VPN/ExpressRoute gateways are configured with availability zone SKU. [#926](https://github.com/Azure/PSRule.Rules.Azure/issues/926)
- General improvements:
  - Improved processing of AzOps generated templates. [#799](https://github.com/Azure/PSRule.Rules.Azure/issues/799)
    - `Azure.Template.DefineParameters` is ignored for AzOps generated templates.
    - `Azure.Template.UseLocationParameter` is ignored for AzOps generated templates.
  - Bicep is now installed when using PSRule GitHub Action. [#1050](https://github.com/Azure/PSRule.Rules.Azure/issues/1050)
- Engineering:
  - Bump PSRule dependency to v1.8.0. [#1018](https://github.com/Azure/PSRule.Rules.Azure/issues/1018)
  - Added automated PR workflow to bump `providers.json` monthly. [#1041](https://github.com/Azure/PSRule.Rules.Azure/issues/1041)
- Bug fixes:
  - Fixed AKS Network Policy should accept calico. [#1046](https://github.com/Azure/PSRule.Rules.Azure/issues/1046)
  - Fixed `Azure.ACR.AdminUser` fails when `adminUserEnabled` not set. [#1014](https://github.com/Azure/PSRule.Rules.Azure/issues/1014)
  - Fixed `Azure.KeyVault.Logs` reports cannot index into a null array. [#1024](https://github.com/Azure/PSRule.Rules.Azure/issues/1024)
  - Fixed template function empty returns object reference not set exception. [#1025](https://github.com/Azure/PSRule.Rules.Azure/issues/1025)
  - Fixed delayed binding of `and` template function. [#1026](https://github.com/Azure/PSRule.Rules.Azure/issues/1026)
  - Fixed template function array nests array with array parameters. [#1027](https://github.com/Azure/PSRule.Rules.Azure/issues/1027)
  - Fixed property used by `Azure.ACR.MinSKU` to work more reliably with templates. [#1034](https://github.com/Azure/PSRule.Rules.Azure/issues/1034)
  - Fixed could not determine JSON object type for MockMember using CreateObject. [#1035](https://github.com/Azure/PSRule.Rules.Azure/issues/1035)
  - Fixed Bicep convention ordering. [#1053](https://github.com/Azure/PSRule.Rules.Azure/issues/1053)

What's changed since pre-release v1.9.0-B2110087:

- No additional changes.

## v1.9.0-B2110087 (pre-release)

What's changed since pre-release v1.9.0-B2110082:

- Bug fixes:
  - Fixed Bicep convention ordering. [#1053](https://github.com/Azure/PSRule.Rules.Azure/issues/1053)

## v1.9.0-B2110082 (pre-release)

What's changed since pre-release v1.9.0-B2110059:

- General improvements:
  - Bicep is now installed when using PSRule GitHub Action. [#1050](https://github.com/Azure/PSRule.Rules.Azure/issues/1050)
- Engineering:
  - Added automated PR workflow to bump `providers.json` monthly. [#1041](https://github.com/Azure/PSRule.Rules.Azure/issues/1041)
- Bug fixes:
  - Fixed AKS Network Policy should accept calico. [#1046](https://github.com/Azure/PSRule.Rules.Azure/issues/1046)

## v1.9.0-B2110059 (pre-release)

What's changed since pre-release v1.9.0-B2110040:

- New rules:
  - API Management Service:
    - Check API management services are using availability zones when available. [#1017](https://github.com/Azure/PSRule.Rules.Azure/issues/1017)
- Bug fixes:
  - Fixed property used by `Azure.ACR.MinSKU` to work more reliably with templates. [#1034](https://github.com/Azure/PSRule.Rules.Azure/issues/1034)
  - Fixed could not determine JSON object type for MockMember using CreateObject. [#1035](https://github.com/Azure/PSRule.Rules.Azure/issues/1035)

## v1.9.0-B2110040 (pre-release)

What's changed since pre-release v1.9.0-B2110025:

- New rules:
  - User Assigned Managed Identity:
    - Check identities meet naming requirements. [#1021](https://github.com/Azure/PSRule.Rules.Azure/issues/1021)
- Bug fixes:
  - Fixed `Azure.KeyVault.Logs` reports cannot index into a null array. [#1024](https://github.com/Azure/PSRule.Rules.Azure/issues/1024)
  - Fixed template function empty returns object reference not set exception. [#1025](https://github.com/Azure/PSRule.Rules.Azure/issues/1025)
  - Fixed delayed binding of `and` template function. [#1026](https://github.com/Azure/PSRule.Rules.Azure/issues/1026)
  - Fixed template function array nests array with array parameters. [#1027](https://github.com/Azure/PSRule.Rules.Azure/issues/1027)

## v1.9.0-B2110025 (pre-release)

What's changed since pre-release v1.9.0-B2110014:

- Engineering:
  - Bump PSRule dependency to v1.8.0. [#1018](https://github.com/Azure/PSRule.Rules.Azure/issues/1018)
- Bug fixes:
  - Fixed `Azure.ACR.AdminUser` fails when `adminUserEnabled` not set. [#1014](https://github.com/Azure/PSRule.Rules.Azure/issues/1014)

## v1.9.0-B2110014 (pre-release)

What's changed since pre-release v1.9.0-B2110009:

- Bug fixes:
  - Fixed expression out of range of valid values. [#1005](https://github.com/Azure/PSRule.Rules.Azure/issues/1005)
  - Fixed template expand fails in nested reference expansion. [#1007](https://github.com/Azure/PSRule.Rules.Azure/issues/1007)

## v1.9.0-B2110009 (pre-release)

What's changed since pre-release v1.9.0-B2109027:

- Bug fixes:
  - Fixed handling of comments with template and parameter file rules. [#996](https://github.com/Azure/PSRule.Rules.Azure/issues/996)
  - Fixed `Azure.Template.UseLocationParameter` to only apply to templates deployed as RG scope [#995](https://github.com/Azure/PSRule.Rules.Azure/issues/995)
  - Fixed expand template fails with `createObject` when no parameters are specified. [#1000](https://github.com/Azure/PSRule.Rules.Azure/issues/1000)

## v1.9.0-B2109027 (pre-release)

What's changed since v1.8.0:

- New rules:
  - Public IP Address:
    - Check Public IP addresses are configured with zone-redundancy. [#958](https://github.com/Azure/PSRule.Rules.Azure/issues/958)
    - Check Public IP addresses are using Standard SKU. [#979](https://github.com/Azure/PSRule.Rules.Azure/issues/979)
  - Virtual Network Gateway:
    - Check VPN/ExpressRoute gateways are configured with availability zone SKU. [#926](https://github.com/Azure/PSRule.Rules.Azure/issues/926)
- General improvements:
  - Improved processing of AzOps generated templates. [#799](https://github.com/Azure/PSRule.Rules.Azure/issues/799)
    - `Azure.Template.DefineParameters` is ignored for AzOps generated templates.
    - `Azure.Template.UseLocationParameter` is ignored for AzOps generated templates.
- Bug fixes:
  - Fixed `ToUpper` fails to convert character. [#986](https://github.com/Azure/PSRule.Rules.Azure/issues/986)

## v1.8.1

What's changed since v1.8.0:

- Bug fixes:
  - Fixed handling of comments with template and parameter file rules. [#996](https://github.com/Azure/PSRule.Rules.Azure/issues/996)
  - Fixed `Azure.Template.UseLocationParameter` to only apply to templates deployed as RG scope [#995](https://github.com/Azure/PSRule.Rules.Azure/issues/995)
  - Fixed expand template fails with `createObject` when no parameters are specified. [#1000](https://github.com/Azure/PSRule.Rules.Azure/issues/1000)
  - Fixed `ToUpper` fails to convert character. [#986](https://github.com/Azure/PSRule.Rules.Azure/issues/986)
  - Fixed expression out of range of valid values. [#1005](https://github.com/Azure/PSRule.Rules.Azure/issues/1005)
  - Fixed template expand fails in nested reference expansion. [#1007](https://github.com/Azure/PSRule.Rules.Azure/issues/1007)

## v1.8.0

What's changed since v1.7.0:

- New features:
  - Added `Azure.GA_2021_09` baseline. [#961](https://github.com/Azure/PSRule.Rules.Azure/issues/961)
    - Includes rules released before or during September 2021 for Azure GA features.
    - Marked baseline `Azure.GA_2021_06` as obsolete.
- New rules:
  - Application Gateway:
    - Check App Gateways should use availability zones when available. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#928](https://github.com/Azure/PSRule.Rules.Azure/issues/928)
  - Azure Kubernetes Service:
    - Check clusters have control plane audit logs enabled. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#882](https://github.com/Azure/PSRule.Rules.Azure/issues/882)
    - Check clusters have control plane diagnostics enabled. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#922](https://github.com/Azure/PSRule.Rules.Azure/issues/922)
    - Check clusters use Container Insights for monitoring workloads. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#881](https://github.com/Azure/PSRule.Rules.Azure/issues/881)
    - Check clusters use availability zones when available. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#880](https://github.com/Azure/PSRule.Rules.Azure/issues/880)
  - Cosmos DB:
    - Check DB account names meet naming requirements. [#954](https://github.com/Azure/PSRule.Rules.Azure/issues/954)
    - Check DB accounts use Azure AD identities for resource management operations. [#953](https://github.com/Azure/PSRule.Rules.Azure/issues/953)
  - Load Balancer:
    - Check Load balancers are using Standard SKU. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#957](https://github.com/Azure/PSRule.Rules.Azure/issues/957)
    - Check Load Balancers are configured with zone-redundancy. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#927](https://github.com/Azure/PSRule.Rules.Azure/issues/927)
- Engineering:
  - Bump PSRule dependency to v1.7.2. [#951](https://github.com/Azure/PSRule.Rules.Azure/issues/951)
  - Automated update of availability zone information in providers.json. [#907](https://github.com/Azure/PSRule.Rules.Azure/issues/907)
  - Increased test coverage of rule reasons. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#960](https://github.com/Azure/PSRule.Rules.Azure/issues/960)
- Bug fixes:
  - Fixed export of in-flight AKS related subnets for kubenet clusters. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#920](https://github.com/Azure/PSRule.Rules.Azure/issues/920)
  - Fixed plan instance count is not applicable to Elastic Premium plans. [#946](https://github.com/Azure/PSRule.Rules.Azure/issues/946)
  - Fixed minimum App Service Plan fails Elastic Premium plans. [#945](https://github.com/Azure/PSRule.Rules.Azure/issues/945)
  - Fixed App Service Plan should include PremiumV3 plan. [#944](https://github.com/Azure/PSRule.Rules.Azure/issues/944)
  - Fixed Azure.VM.NICAttached with private endpoints. [#932](https://github.com/Azure/PSRule.Rules.Azure/issues/932)
  - Fixed Bicep CLI fails with unexpected end of content. [#889](https://github.com/Azure/PSRule.Rules.Azure/issues/889)
  - Fixed incomplete reason message for `Azure.Storage.MinTLS`. [#971](https://github.com/Azure/PSRule.Rules.Azure/issues/971)
  - Fixed false positive of `Azure.Storage.UseReplication` with large file storage. [#965](https://github.com/Azure/PSRule.Rules.Azure/issues/965)

What's changed since pre-release v1.8.0-B2109060:

- No additional changes.

## v1.8.0-B2109086 (pre-release)

What's changed since pre-release v1.8.0-B2109060:

- New rules:
  - Load Balancer:
    - Check Load balancers are using Standard SKU. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#957](https://github.com/Azure/PSRule.Rules.Azure/issues/957)
- Engineering:
  - Increased test coverage of rule reasons. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#960](https://github.com/Azure/PSRule.Rules.Azure/issues/960)
- Bug fixes:
  - Fixed Bicep CLI fails with unexpected end of content. [#889](https://github.com/Azure/PSRule.Rules.Azure/issues/889)
  - Fixed incomplete reason message for `Azure.Storage.MinTLS`. [#971](https://github.com/Azure/PSRule.Rules.Azure/issues/971)
  - Fixed false positive of `Azure.Storage.UseReplication` with large file storage. [#965](https://github.com/Azure/PSRule.Rules.Azure/issues/965)

## v1.8.0-B2109060 (pre-release)

What's changed since pre-release v1.8.0-B2109046:

- New features:
  - Added `Azure.GA_2021_09` baseline. [#961](https://github.com/Azure/PSRule.Rules.Azure/issues/961)
    - Includes rules released before or during September 2021 for Azure GA features.
    - Marked baseline `Azure.GA_2021_06` as obsolete.
- New rules:
  - Load Balancer:
    - Check Load Balancers are configured with zone-redundancy. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#927](https://github.com/Azure/PSRule.Rules.Azure/issues/927)

## v1.8.0-B2109046 (pre-release)

What's changed since pre-release v1.8.0-B2109020:

- New rules:
  - Application Gateway:
    - Check App Gateways should use availability zones when available. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#928](https://github.com/Azure/PSRule.Rules.Azure/issues/928)
  - Cosmos DB:
    - Check DB account names meet naming requirements. [#954](https://github.com/Azure/PSRule.Rules.Azure/issues/954)
    - Check DB accounts use Azure AD identities for resource management operations. [#953](https://github.com/Azure/PSRule.Rules.Azure/issues/953)
- Bug fixes:
  - Fixed plan instance count is not applicable to Elastic Premium plans. [#946](https://github.com/Azure/PSRule.Rules.Azure/issues/946)
  - Fixed minimum App Service Plan fails Elastic Premium plans. [#945](https://github.com/Azure/PSRule.Rules.Azure/issues/945)
  - Fixed App Service Plan should include PremiumV3 plan. [#944](https://github.com/Azure/PSRule.Rules.Azure/issues/944)
  - Fixed Azure.VM.NICAttached with private endpoints. [#932](https://github.com/Azure/PSRule.Rules.Azure/issues/932)
- Engineering:
  - Bump PSRule dependency to v1.7.2. [#951](https://github.com/Azure/PSRule.Rules.Azure/issues/951)

## v1.8.0-B2109020 (pre-release)

What's changed since pre-release v1.8.0-B2108026:

- New rules:
  - Azure Kubernetes Service:
    - Check clusters have control plane audit logs enabled. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#882](https://github.com/Azure/PSRule.Rules.Azure/issues/882)
    - Check clusters have control plane diagnostics enabled. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#922](https://github.com/Azure/PSRule.Rules.Azure/issues/922)
- Engineering:
  - Bump PSRule dependency to v1.7.0. [#938](https://github.com/Azure/PSRule.Rules.Azure/issues/938)

## v1.8.0-B2108026 (pre-release)

What's changed since pre-release v1.8.0-B2108013:

- New rules:
  - Azure Kubernetes Service:
    - Check clusters use Container Insights for monitoring workloads. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#881](https://github.com/Azure/PSRule.Rules.Azure/issues/881)
- Bug fixes:
  - Fixed export of in-flight AKS related subnets for kubenet clusters. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#920](https://github.com/Azure/PSRule.Rules.Azure/issues/920)

## v1.8.0-B2108013 (pre-release)

What's changed since v1.7.0:

- New rules:
  - Azure Kubernetes Service:
    - Check clusters use availability zones when available. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#880](https://github.com/Azure/PSRule.Rules.Azure/issues/880)
- Engineering:
  - Bump PSRule dependency to v1.6.1. [#913](https://github.com/Azure/PSRule.Rules.Azure/issues/913)
  - Automated update of availability zone information in providers.json. [#907](https://github.com/Azure/PSRule.Rules.Azure/issues/907)

## v1.7.0

What's changed since v1.6.0:

- New rules:
  - All resources:
    - Check template parameter files use metadata links. [#846](https://github.com/Azure/PSRule.Rules.Azure/issues/846)
      - Configure the `AZURE_PARAMETER_FILE_METADATA_LINK` option to enable this rule.
    - Check template files use a recent schema. [#845](https://github.com/Azure/PSRule.Rules.Azure/issues/845)
    - Check template files use a https schema scheme. [#894](https://github.com/Azure/PSRule.Rules.Azure/issues/894)
    - Check template parameter files use a https schema scheme. [#894](https://github.com/Azure/PSRule.Rules.Azure/issues/894)
    - Check template parameters set a value. [#896](https://github.com/Azure/PSRule.Rules.Azure/issues/896)
    - Check template parameters use a valid secret reference. [#897](https://github.com/Azure/PSRule.Rules.Azure/issues/897)
  - Azure Kubernetes Service:
    - Check clusters using Azure CNI should use large subnets. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#273](https://github.com/Azure/PSRule.Rules.Azure/issues/273)
    - Check clusters use auto-scale node pools. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#218](https://github.com/Azure/PSRule.Rules.Azure/issues/218)
      - By default, a minimum of a `/23` subnet is required.
      - Configure `AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE` to change the default minimum subnet size.
  - Storage Account:
    - Check Storage Accounts only accept explicitly allowed network traffic. [#884](https://github.com/Azure/PSRule.Rules.Azure/issues/884)
- Updated rules:
  - Virtual Network:
    - Excluded `AzureFirewallManagementSubnet` from `Azure.VNET.UseNSGs`. [#869](https://github.com/Azure/PSRule.Rules.Azure/issues/869)
- General improvements:
  - Added version information to bicep compilation exceptions. [#903](https://github.com/Azure/PSRule.Rules.Azure/issues/903)
- Engineering:
  - Bump PSRule dependency to v1.6.0. [#871](https://github.com/Azure/PSRule.Rules.Azure/issues/871)
- Bug fixes:
  - Fixed DateTimeAdd function and tests within timezones with DST. [#891](https://github.com/Azure/PSRule.Rules.Azure/issues/891)
  - Fixed `Azure.Template.ParameterValue` failing on empty value. [#901](https://github.com/Azure/PSRule.Rules.Azure/issues/901)

What's changed since pre-release v1.7.0-B2108059:

- No additional changes.

## v1.7.0-B2108059 (pre-release)

What's changed since pre-release v1.7.0-B2108049:

- General improvements:
  - Added version information to bicep compilation exceptions. [#903](https://github.com/Azure/PSRule.Rules.Azure/issues/903)
- Bug fixes:
  - Fixed `Azure.Template.ParameterValue` failing on empty value. [#901](https://github.com/Azure/PSRule.Rules.Azure/issues/901)

## v1.7.0-B2108049 (pre-release)

What's changed since pre-release v1.7.0-B2108040:

- New rules:
  - All resources:
    - Check template files use a recent schema. [#845](https://github.com/Azure/PSRule.Rules.Azure/issues/845)
    - Check template files use a https schema scheme. [#894](https://github.com/Azure/PSRule.Rules.Azure/issues/894)
    - Check template parameter files use a https schema scheme. [#894](https://github.com/Azure/PSRule.Rules.Azure/issues/894)
    - Check template parameters set a value. [#896](https://github.com/Azure/PSRule.Rules.Azure/issues/896)
    - Check template parameters use a valid secret reference. [#897](https://github.com/Azure/PSRule.Rules.Azure/issues/897)
- Bug fixes:
  - Fixed DateTimeAdd function and tests within timezones with DST. [#891](https://github.com/Azure/PSRule.Rules.Azure/issues/891)

## v1.7.0-B2108040 (pre-release)

What's changed since pre-release v1.7.0-B2108020:

- New rules:
  - All resources:
    - Check template parameter files use metadata links. [#846](https://github.com/Azure/PSRule.Rules.Azure/issues/846)
      - Configure the `AZURE_PARAMETER_FILE_METADATA_LINK` option to enable this rule.
  - Azure Kubernetes Service:
    - Check clusters using Azure CNI should use large subnets. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#273](https://github.com/Azure/PSRule.Rules.Azure/issues/273)
      - By default, a minimum of a `/23` subnet is required.
      - Configure `AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE` to change the default minimum subnet size.
  - Storage Account:
    - Check Storage Accounts only accept explicitly allowed network traffic. [#884](https://github.com/Azure/PSRule.Rules.Azure/issues/884)

## v1.7.0-B2108020 (pre-release)

What's changed since v1.6.0:

- New rules:
  - Azure Kubernetes Service:
    - Check clusters use auto-scale node pools. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#218](https://github.com/Azure/PSRule.Rules.Azure/issues/218)
- Updated rules:
  - Virtual Network:
    - Excluded `AzureFirewallManagementSubnet` from `Azure.VNET.UseNSGs`. [#869](https://github.com/Azure/PSRule.Rules.Azure/issues/869)
- Engineering:
  - Bump PSRule dependency to v1.6.0. [#871](https://github.com/Azure/PSRule.Rules.Azure/issues/871)

## v1.6.0

What's changed since v1.5.1:

- New features:
  - **Experimental**: Added support for expansion from Bicep source files. [#848](https://github.com/Azure/PSRule.Rules.Azure/issues/848) [#670](https://github.com/Azure/PSRule.Rules.Azure/issues/670) [#858](https://github.com/Azure/PSRule.Rules.Azure/issues/858)
    - Bicep support is currently experimental.
    - To opt-in set the `AZURE_BICEP_FILE_EXPANSION` configuration to `true`.
    - For more information see [Using Bicep](https://azure.github.io/PSRule.Rules.Azure/using-bicep/).
- New rules:
  - Application Gateways:
    - Check Application Gateways publish endpoints by HTTPS. [#841](https://github.com/Azure/PSRule.Rules.Azure/issues/841)
- Engineering:
  - Bump PSRule dependency to v1.5.0. [#832](https://github.com/Azure/PSRule.Rules.Azure/issues/832)
  - Migration of Pester v4 tests to Pester v5. Thanks [@ArmaanMcleod](https://github.com/ArmaanMcleod). [#395](https://github.com/Azure/PSRule.Rules.Azure/issues/395)

What's changed since pre-release v1.6.0-B2108038:

- Bug fixes:
  - Fixed Bicep expand creates deadlock and times out. [#863](https://github.com/Azure/PSRule.Rules.Azure/issues/863)

## v1.6.0-B2108038 (pre-release)

What's changed since pre-release v1.6.0-B2108023:

- Bug fixes:
  - Fixed Bicep expand hangs analysis. [#858](https://github.com/Azure/PSRule.Rules.Azure/issues/858)

## v1.6.0-B2108023 (pre-release)

What's changed since pre-release v1.6.0-B2107028:

- New features:
  - **Experimental**: Added support for expansion from Bicep source files. [#848](https://github.com/Azure/PSRule.Rules.Azure/issues/848) [#670](https://github.com/Azure/PSRule.Rules.Azure/issues/670)
    - Bicep support is currently experimental.
    - To opt-in set the `AZURE_BICEP_FILE_EXPANSION` configuration to `true`.
    - For more information see [Using Bicep](https://azure.github.io/PSRule.Rules.Azure/using-bicep/).

## v1.6.0-B2107028 (pre-release)

What's changed since v1.5.1:

- New rules:
  - Application Gateways:
    - Check Application Gateways publish endpoints by HTTPS. [#841](https://github.com/Azure/PSRule.Rules.Azure/issues/841)
- Engineering:
  - Bump PSRule dependency to v1.5.0. [#832](https://github.com/Azure/PSRule.Rules.Azure/issues/832)

## v1.5.1

What's changed since v1.5.0:

- Bug fixes:
  - Fixed rule does not detect more restrictive NSG rules. [#831](https://github.com/Azure/PSRule.Rules.Azure/issues/831)

## v1.5.0

What's changed since v1.4.1:

- New features:
  - Added `Azure.GA_2021_06` baseline. [#822](https://github.com/Azure/PSRule.Rules.Azure/issues/822)
    - Includes rules released before or during June 2021 for Azure GA features.
    - Marked baseline `Azure.GA_2021_03` as obsolete.
- New rules:
  - Application Insights:
    - Check App Insights resources use workspace-based configuration. [#813](https://github.com/Azure/PSRule.Rules.Azure/issues/813)
    - Check App Insights resources meet naming requirements. [#814](https://github.com/Azure/PSRule.Rules.Azure/issues/814)
- General improvements:
  - Exclude not applicable rules for templates generated with Bicep and PSArm. [#815](https://github.com/Azure/PSRule.Rules.Azure/issues/815)
  - Updated rule help to use docs pages for online version. [#824](https://github.com/Azure/PSRule.Rules.Azure/issues/824)
- Engineering:
  - Bump PSRule dependency to v1.4.0. [#823](https://github.com/Azure/PSRule.Rules.Azure/issues/823)
  - Bump YamlDotNet dependency to v11.2.1. [#821](https://github.com/Azure/PSRule.Rules.Azure/pull/821)
  - Migrate project to Azure GitHub organization and updated links. [#800](https://github.com/Azure/PSRule.Rules.Azure/pull/800)
- Bug fixes:
  - Fixed detection of parameters and variables with line breaks. [#811](https://github.com/Azure/PSRule.Rules.Azure/issues/811)

What's changed since pre-release v1.5.0-B2107002:

- No additional changes.

## v1.5.0-B2107002 (pre-release)

What's changed since pre-release v1.5.0-B2106018:

- New features:
  - Added `Azure.GA_2021_06` baseline. [#822](https://github.com/Azure/PSRule.Rules.Azure/issues/822)
    - Includes rules released before or during June 2021 for Azure GA features.
    - Marked baseline `Azure.GA_2021_03` as obsolete.
- General improvements:
  - Updated rule help to use docs pages for online version. [#824](https://github.com/Azure/PSRule.Rules.Azure/issues/824)
- Engineering:
  - Bump PSRule dependency to v1.4.0. [#823](https://github.com/Azure/PSRule.Rules.Azure/issues/823)
  - Bump YamlDotNet dependency to v11.2.1. [#821](https://github.com/Azure/PSRule.Rules.Azure/pull/821)

## v1.5.0-B2106018 (pre-release)

What's changed since v1.4.1:

- New rules:
  - Application Insights:
    - Check App Insights resources use workspace-based configuration. [#813](https://github.com/Azure/PSRule.Rules.Azure/issues/813)
    - Check App Insights resources meet naming requirements. [#814](https://github.com/Azure/PSRule.Rules.Azure/issues/814)
- General improvements:
  - Exclude not applicable rules for templates generated with Bicep and PSArm. [#815](https://github.com/Azure/PSRule.Rules.Azure/issues/815)
- Engineering:
  - Bump YamlDotNet dependency to v11.2.0. [#801](https://github.com/Azure/PSRule.Rules.Azure/pull/801)
  - Migrate project to Azure GitHub organization and updated links. [#800](https://github.com/Azure/PSRule.Rules.Azure/pull/800)
- Bug fixes:
  - Fixed detection of parameters and variables with line breaks. [#811](https://github.com/Azure/PSRule.Rules.Azure/issues/811)

## v1.4.1

What's changed since v1.4.0:

- Bug fixes:
  - Fixed boolean string conversion case. [#793](https://github.com/Azure/PSRule.Rules.Azure/issues/793)
  - Fixed case sensitive property matching. [#794](https://github.com/Azure/PSRule.Rules.Azure/issues/794)
  - Fixed automatic expansion of template parameter files. [#796](https://github.com/Azure/PSRule.Rules.Azure/issues/796)
    - Template parameter files are not automatically expanded by default.
    - To enable this, set the `AZURE_PARAMETER_FILE_EXPANSION` configuration option.

## v1.4.0

What's changed since v1.3.2:

- New features:
  - Automatically expand template from parameter files for analysis. [#772](https://github.com/Azure/PSRule.Rules.Azure/issues/772)
    - Previously templates needed to be exported with `Export-AzRuleTemplateData`.
    - To export template data automatically use PSRule cmdlets with `-Format File`.
- New rules:
  - Cognitive Search:
    - Check search services meet index SLA replica requirement. [#761](https://github.com/Azure/PSRule.Rules.Azure/issues/761)
    - Check search services meet query SLA replica requirement. [#762](https://github.com/Azure/PSRule.Rules.Azure/issues/762)
    - Check search services meet naming requirements. [#763](https://github.com/Azure/PSRule.Rules.Azure/issues/763)
    - Check search services use a minimum SKU. [#764](https://github.com/Azure/PSRule.Rules.Azure/issues/764)
    - Check search services use managed identities. [#765](https://github.com/Azure/PSRule.Rules.Azure/issues/765)
  - Azure Kubernetes Service:
    - Check clusters use AKS-managed Azure AD integration. [#436](https://github.com/Azure/PSRule.Rules.Azure/issues/436)
    - Check clusters have local account disabled (preview). [#786](https://github.com/Azure/PSRule.Rules.Azure/issues/786)
    - Check clusters have an auto-upgrade channel set (preview). [#787](https://github.com/Azure/PSRule.Rules.Azure/issues/787)
    - Check clusters limit access network access to the API server. [#788](https://github.com/Azure/PSRule.Rules.Azure/issues/788)
    - Check clusters used Azure RBAC for Kubernetes authorization. [#789](https://github.com/Azure/PSRule.Rules.Azure/issues/789)
- Updated rules:
  - Azure Kubernetes Service:
    - Updated `Azure.AKS.Version` to 1.20.5. [#767](https://github.com/Azure/PSRule.Rules.Azure/issues/767)
- General improvements:
  - Automatically nest template sub-resources for analysis. [#746](https://github.com/Azure/PSRule.Rules.Azure/issues/746)
    - Sub-resources such as diagnostic logs or configurations are automatically nested.
    - Automatic nesting a resource requires:
      - The parent resource is defined in the same template.
      - The sub-resource depends on the parent resource.
  - Added support for source location references to template files. [#781](https://github.com/Azure/PSRule.Rules.Azure/issues/781)
    - Output includes source location to resources exported from a templates.
- Bug fixes:
  - Fixed string index parsing in expressions with whitespace. [#775](https://github.com/Azure/PSRule.Rules.Azure/issues/775)
  - Fixed base for DateTimeAdd is not a valid string. [#777](https://github.com/Azure/PSRule.Rules.Azure/issues/777)
- Engineering:
  - Added source link to project. [#783](https://github.com/Azure/PSRule.Rules.Azure/issues/783)

What's changed since pre-release v1.4.0-B2105057:

- No additional changes.

## v1.4.0-B2105057 (pre-release)

What's changed since pre-release v1.4.0-B2105050:

- New rules:
  - Azure Kubernetes Service:
    - Check clusters use AKS-managed Azure AD integration. [#436](https://github.com/Azure/PSRule.Rules.Azure/issues/436)
    - Check clusters have local account disabled (preview). [#786](https://github.com/Azure/PSRule.Rules.Azure/issues/786)
    - Check clusters have an auto-upgrade channel set (preview). [#787](https://github.com/Azure/PSRule.Rules.Azure/issues/787)
    - Check clusters limit access network access to the API server. [#788](https://github.com/Azure/PSRule.Rules.Azure/issues/788)
    - Check clusters used Azure RBAC for Kubernetes authorization. [#789](https://github.com/Azure/PSRule.Rules.Azure/issues/789)
- Updated rules:
  - Azure Kubernetes Service:
    - Updated `Azure.AKS.Version` to 1.20.5. [#767](https://github.com/Azure/PSRule.Rules.Azure/issues/767)
- Engineering:
  - Added source link to project. [#783](https://github.com/Azure/PSRule.Rules.Azure/issues/783)

## v1.4.0-B2105050 (pre-release)

What's changed since pre-release v1.4.0-B2105044:

- General improvements:
  - Added support for source location references to template files. [#781](https://github.com/Azure/PSRule.Rules.Azure/issues/781)
    - Output includes source location to resources exported from a templates.

## v1.4.0-B2105044 (pre-release)

What's changed since pre-release v1.4.0-B2105027:

- New features:
  - Automatically expand template from parameter files for analysis. [#772](https://github.com/Azure/PSRule.Rules.Azure/issues/772)
    - Previously templates needed to be exported with `Export-AzRuleTemplateData`.
    - To export template data automatically use PSRule cmdlets with `-Format File`.
- Bug fixes:
  - Fixed string index parsing in expressions with whitespace. [#775](https://github.com/Azure/PSRule.Rules.Azure/issues/775)
  - Fixed base for DateTimeAdd is not a valid string. [#777](https://github.com/Azure/PSRule.Rules.Azure/issues/777)

## v1.4.0-B2105027 (pre-release)

What's changed since pre-release v1.4.0-B2105020:

- New rules:
  - Cognitive Search:
    - Check search services meet index SLA replica requirement. [#761](https://github.com/Azure/PSRule.Rules.Azure/issues/761)
    - Check search services meet query SLA replica requirement. [#762](https://github.com/Azure/PSRule.Rules.Azure/issues/762)
    - Check search services meet naming requirements. [#763](https://github.com/Azure/PSRule.Rules.Azure/issues/763)
    - Check search services use a minimum SKU. [#764](https://github.com/Azure/PSRule.Rules.Azure/issues/764)
    - Check search services use managed identities. [#765](https://github.com/Azure/PSRule.Rules.Azure/issues/765)

## v1.4.0-B2105020 (pre-release)

What's changed since v1.3.2:

- General improvements:
  - Automatically nest template sub-resources for analysis. [#746](https://github.com/Azure/PSRule.Rules.Azure/issues/746)
    - Sub-resources such as diagnostic logs or configurations are automatically nested.
    - Automatic nesting a resource requires:
      - The parent resource is defined in the same template.
      - The sub-resource depends on the parent resource.

## v1.3.2

What's changed since v1.3.1:

- Bug fixes:
  - Fixed rule reason reported the parameter inputObject is null. [#753](https://github.com/Azure/PSRule.Rules.Azure/issues/753)

## v1.3.1

What's changed since v1.3.0:

- Engineering:
  - Bump PSRule dependency to v1.3.0. [#749](https://github.com/Azure/PSRule.Rules.Azure/issues/749)
  - Bump YamlDotNet dependency to v11.1.1. [#742](https://github.com/Azure/PSRule.Rules.Azure/issues/742)

## v1.3.0

What's changed since v1.2.1:

- New rules:
  - Policy:
    - Check policy assignment display name and description are set. [#725](https://github.com/Azure/PSRule.Rules.Azure/issues/725)
    - Check policy assignment assigned by metadata is set. [#726](https://github.com/Azure/PSRule.Rules.Azure/issues/726)
    - Check policy exemption display name and description are set. [#723](https://github.com/Azure/PSRule.Rules.Azure/issues/723)
    - Check policy waiver exemptions have an expiry date set. [#724](https://github.com/Azure/PSRule.Rules.Azure/issues/724)
- Removed rules:
  - Storage:
    - Remove `Azure.Storage.UseEncryption` as Storage Service Encryption (SSE) is always on. [#630](https://github.com/Azure/PSRule.Rules.Azure/issues/630)
      - SSE is on by default and can not be disabled.
- General improvements:
  - Additional metadata added in parameter files is passed through with `Get-AzRuleTemplateLink`. [#706](https://github.com/Azure/PSRule.Rules.Azure/issues/706)
  - Improved binding support for File inputs. [#480](https://github.com/Azure/PSRule.Rules.Azure/issues/480)
    - Template and parameter file names now return a relative path instead of full path.
  - Added API version for each module resource. [#729](https://github.com/Azure/PSRule.Rules.Azure/issues/729)
- Engineering:
  - Clean up depreciated warning message for configuration option `azureAllowedRegions`. [#737](https://github.com/Azure/PSRule.Rules.Azure/issues/737)
  - Clean up depreciated warning message for configuration option `minAKSVersion`. [#738](https://github.com/Azure/PSRule.Rules.Azure/issues/738)
  - Bump PSRule dependency to v1.2.0. [#713](https://github.com/Azure/PSRule.Rules.Azure/issues/713)
- Bug fixes:
  - Fixed could not load file or assembly YamlDotNet. [#741](https://github.com/Azure/PSRule.Rules.Azure/issues/741)
    - This fix pins the PSRule version to v1.2.0 until the next stable release of PSRule for Azure.

What's changed since pre-release v1.3.0-B2104040:

- No additional changes.

## v1.3.0-B2104040 (pre-release)

What's changed since pre-release v1.3.0-B2104034:

- Bug fixes:
  - Fixed could not load file or assembly YamlDotNet. [#741](https://github.com/Azure/PSRule.Rules.Azure/issues/741)
    - This fix pins the PSRule version to v1.2.0 until the next stable release of PSRule for Azure.

## v1.3.0-B2104034 (pre-release)

What's changed since pre-release v1.3.0-B2104023:

- New rules:
  - Policy:
    - Check policy assignment display name and description are set. [#725](https://github.com/Azure/PSRule.Rules.Azure/issues/725)
    - Check policy assignment assigned by metadata is set. [#726](https://github.com/Azure/PSRule.Rules.Azure/issues/726)
    - Check policy exemption display name and description are set. [#723](https://github.com/Azure/PSRule.Rules.Azure/issues/723)
    - Check policy waiver exemptions have an expiry date set. [#724](https://github.com/Azure/PSRule.Rules.Azure/issues/724)
- Engineering:
  - Clean up depreciated warning message for configuration option `azureAllowedRegions`. [#737](https://github.com/Azure/PSRule.Rules.Azure/issues/737)
  - Clean up depreciated warning message for configuration option `minAKSVersion`. [#738](https://github.com/Azure/PSRule.Rules.Azure/issues/738)

## v1.3.0-B2104023 (pre-release)

What's changed since pre-release v1.3.0-B2104013:

- General improvements:
  - Improved binding support for File inputs. [#480](https://github.com/Azure/PSRule.Rules.Azure/issues/480)
    - Template and parameter file names now return a relative path instead of full path.
  - Added API version for each module resource. [#729](https://github.com/Azure/PSRule.Rules.Azure/issues/729)

## v1.3.0-B2104013 (pre-release)

What's changed since pre-release v1.3.0-B2103007:

- Engineering:
  - Bump PSRule dependency to v1.2.0. [#713](https://github.com/Azure/PSRule.Rules.Azure/issues/713)
- Bug fixes:
  - Fixed export not expanding nested deployments. [#715](https://github.com/Azure/PSRule.Rules.Azure/issues/715)

## v1.3.0-B2103007 (pre-release)

What's changed since v1.2.0:

- Removed rules:
  - Storage:
    - Remove `Azure.Storage.UseEncryption` as Storage Service Encryption (SSE) is always on. [#630](https://github.com/Azure/PSRule.Rules.Azure/issues/630)
      - SSE is on by default and can not be disabled.
- General improvements:
  - Additional metadata added in parameter files is passed through with `Get-AzRuleTemplateLink`. [#706](https://github.com/Azure/PSRule.Rules.Azure/issues/706)

## v1.2.1

What's changed since v1.2.0:

- Bug fixes:
  - Fixed export not expanding nested deployments. [#715](https://github.com/Azure/PSRule.Rules.Azure/issues/715)

## v1.2.0

What's changed since v1.1.4:

- New features:
  - Added `Azure.GA_2021_03` baseline. [#673](https://github.com/Azure/PSRule.Rules.Azure/issues/673)
    - Includes rules released before or during March 2021 for Azure GA features.
    - Marked baseline `Azure.GA_2020_12` as obsolete.
- New rules:
  - Key Vault:
    - Check vaults, keys, and secrets meet name requirements. [#646](https://github.com/Azure/PSRule.Rules.Azure/issues/646)
- Updated rules:
  - Azure Kubernetes Service:
    - Updated `Azure.AKS.Version` to 1.19.7. [#696](https://github.com/Azure/PSRule.Rules.Azure/issues/696)
- General improvements:
  - Added support for user defined functions in templates. [#682](https://github.com/Azure/PSRule.Rules.Azure/issues/682)
- Engineering:
  - Bump PSRule dependency to v1.1.0. [#692](https://github.com/Azure/PSRule.Rules.Azure/issues/692)

What's changed since pre-release v1.2.0-B2103044:

- No additional changes.

## v1.2.0-B2103044 (pre-release)

What's changed since pre-release v1.2.0-B2103032:

- New features:
  - Added `Azure.GA_2021_03` baseline. [#673](https://github.com/Azure/PSRule.Rules.Azure/issues/673)
    - Includes rules released before or during March 2021 for Azure GA features.
    - Marked baseline `Azure.GA_2020_12` as obsolete.
- Updated rules:
  - Azure Kubernetes Service:
    - Updated `Azure.AKS.Version` to 1.19.7. [#696](https://github.com/Azure/PSRule.Rules.Azure/issues/696)

## v1.2.0-B2103032 (pre-release)

What's changed since pre-release v1.2.0-B2103024:

- New rules:
  - Key Vault:
    - Check vaults, keys, and secrets meet name requirements. [#646](https://github.com/Azure/PSRule.Rules.Azure/issues/646)
- Engineering:
  - Bump PSRule dependency to v1.1.0. [#692](https://github.com/Azure/PSRule.Rules.Azure/issues/692)

## v1.2.0-B2103024 (pre-release)

What's changed since v1.1.4:

- General improvements:
  - Added support for user defined functions in templates. [#682](https://github.com/Azure/PSRule.Rules.Azure/issues/682)

## v1.1.4

What's changed since v1.1.3:

- Bug fixes:
  - Fixed handling of literal index with copyIndex function. [#686](https://github.com/Azure/PSRule.Rules.Azure/issues/686)
  - Fixed handling of inner scoped nested deployments. [#687](https://github.com/Azure/PSRule.Rules.Azure/issues/687)

## v1.1.3

What's changed since v1.1.2:

- Bug fixes:
  - Fixed parsing of property names for functions across multiple lines. [#683](https://github.com/Azure/PSRule.Rules.Azure/issues/683)

## v1.1.2

What's changed since v1.1.1:

- Bug fixes:
  - Fixed copy peer property resolve. [#677](https://github.com/Azure/PSRule.Rules.Azure/issues/677)
  - Fixed partial resource group or subscription object not populating. [#678](https://github.com/Azure/PSRule.Rules.Azure/issues/678)
  - Fixed lazy loading of environment and resource providers. [#679](https://github.com/Azure/PSRule.Rules.Azure/issues/679)

## v1.1.1

What's changed since v1.1.0:

- Bug fixes:
  - Fixed support for parameter file schemas. [#674](https://github.com/Azure/PSRule.Rules.Azure/issues/674)

## v1.1.0

What's changed since v1.0.0:

- New features:
  - Exporting template with `Export-AzRuleTemplateData` supports custom resource group and subscription. [#651](https://github.com/Azure/PSRule.Rules.Azure/issues/651)
    - Subscription and resource group used for deployment can be specified instead of using defaults.
    - `ResourceGroupName` parameter of `Export-AzRuleTemplateData` has been renamed to `ResourceGroup`.
    - Added a parameter alias for `ResourceGroupName` on `Export-AzRuleTemplateData`.
- New rules:
  - All resources:
    - Check template parameters are defined. [#631](https://github.com/Azure/PSRule.Rules.Azure/issues/631)
    - Check location parameter is type string. [#632](https://github.com/Azure/PSRule.Rules.Azure/issues/632)
    - Check template parameter `minValue` and `maxValue` constraints are valid. [#637](https://github.com/Azure/PSRule.Rules.Azure/issues/637)
    - Check template resources do not use hard coded locations. [#633](https://github.com/Azure/PSRule.Rules.Azure/issues/633)
    - Check resource group location not referenced instead of location parameter. [#634](https://github.com/Azure/PSRule.Rules.Azure/issues/634)
    - Check increased debug detail is disabled for nested deployments. [#638](https://github.com/Azure/PSRule.Rules.Azure/issues/638)
- General improvements:
  - Added support for matching template by name. [#661](https://github.com/Azure/PSRule.Rules.Azure/issues/661)
    - `Get-AzRuleTemplateLink` discovers `<templateName>.json` from `<templateName>.parameters.json`.
- Engineering:
  - Bump PSRule dependency to v1.0.3. [#648](https://github.com/Azure/PSRule.Rules.Azure/issues/648)
- Bug fixes:
  - Fixed `Azure.VM.ADE` to limit rule to exports only. [#644](https://github.com/Azure/PSRule.Rules.Azure/issues/644)
  - Fixed `if` condition values evaluation order. [#652](https://github.com/Azure/PSRule.Rules.Azure/issues/652)
  - Fixed handling of `int` parameters with large values. [#653](https://github.com/Azure/PSRule.Rules.Azure/issues/653)
  - Fixed handling of expressions split over multiple lines. [#654](https://github.com/Azure/PSRule.Rules.Azure/issues/654)
  - Fixed handling of bool parameter values within logical expressions. [#655](https://github.com/Azure/PSRule.Rules.Azure/issues/655)
  - Fixed copy loop value does not fall within the expected range. [#664](https://github.com/Azure/PSRule.Rules.Azure/issues/664)
  - Fixed template comparison functions handling of large integer values. [#666](https://github.com/Azure/PSRule.Rules.Azure/issues/666)
  - Fixed handling of `createArray` function with no arguments. [#667](https://github.com/Azure/PSRule.Rules.Azure/issues/667)

What's changed since pre-release v1.1.0-B2102034:

- No additional changes.

## v1.1.0-B2102034 (pre-release)

What's changed since pre-release v1.1.0-B2102023:

- General improvements:
  - Added support for matching template by name. [#661](https://github.com/Azure/PSRule.Rules.Azure/issues/661)
    - `Get-AzRuleTemplateLink` discovers `<templateName>.json` from `<templateName>.parameters.json`.
- Bug fixes:
  - Fixed copy loop value does not fall within the expected range. [#664](https://github.com/Azure/PSRule.Rules.Azure/issues/664)
  - Fixed template comparison functions handling of large integer values. [#666](https://github.com/Azure/PSRule.Rules.Azure/issues/666)
  - Fixed handling of `createArray` function with no arguments. [#667](https://github.com/Azure/PSRule.Rules.Azure/issues/667)

## v1.1.0-B2102023 (pre-release)

What's changed since pre-release v1.1.0-B2102015:

- New features:
  - Exporting template with `Export-AzRuleTemplateData` supports custom resource group and subscription. [#651](https://github.com/Azure/PSRule.Rules.Azure/issues/651)
    - Subscription and resource group used for deployment can be specified instead of using defaults.
    - `ResourceGroupName` parameter of `Export-AzRuleTemplateData` has been renamed to `ResourceGroup`.
    - Added a parameter alias for `ResourceGroupName` on `Export-AzRuleTemplateData`.

## v1.1.0-B2102015 (pre-release)

What's changed since pre-release v1.1.0-B2102010:

- Bug fixes:
  - Fixed `if` condition values evaluation order. [#652](https://github.com/Azure/PSRule.Rules.Azure/issues/652)
  - Fixed handling of `int` parameters with large values. [#653](https://github.com/Azure/PSRule.Rules.Azure/issues/653)
  - Fixed handling of expressions split over multiple lines. [#654](https://github.com/Azure/PSRule.Rules.Azure/issues/654)
  - Fixed handling of bool parameter values within logical expressions. [#655](https://github.com/Azure/PSRule.Rules.Azure/issues/655)

## v1.1.0-B2102010 (pre-release)

What's changed since pre-release v1.1.0-B2102001:

- Engineering:
  - Bump PSRule dependency to v1.0.3. [#648](https://github.com/Azure/PSRule.Rules.Azure/issues/648)
- Bug fixes:
  - Fixed `Azure.VM.ADE` to limit rule to exports only. [#644](https://github.com/Azure/PSRule.Rules.Azure/issues/644)

## v1.1.0-B2102001 (pre-release)

What's changed since v1.0.0:

- New rules:
  - All resources:
    - Check template parameters are defined. [#631](https://github.com/Azure/PSRule.Rules.Azure/issues/631)
    - Check location parameter is type string. [#632](https://github.com/Azure/PSRule.Rules.Azure/issues/632)
    - Check template parameter `minValue` and `maxValue` constraints are valid. [#637](https://github.com/Azure/PSRule.Rules.Azure/issues/637)
    - Check template resources do not use hard coded locations. [#633](https://github.com/Azure/PSRule.Rules.Azure/issues/633)
    - Check resource group location not referenced instead of location parameter. [#634](https://github.com/Azure/PSRule.Rules.Azure/issues/634)
    - Check increased debug detail is disabled for nested deployments. [#638](https://github.com/Azure/PSRule.Rules.Azure/issues/638)
- Engineering:
  - Bump PSRule dependency to v1.0.2. [#635](https://github.com/Azure/PSRule.Rules.Azure/issues/635)

## v1.0.0

What's changed since v0.19.0:

- New rules:
  - All resources:
    - Check parameter default value type matches type. [#311](https://github.com/Azure/PSRule.Rules.Azure/issues/311)
    - Check location parameter defaults to resource group. [#361](https://github.com/Azure/PSRule.Rules.Azure/issues/361)
  - Front Door:
    - Check Front Door uses a health probe for each backend pool. [#546](https://github.com/Azure/PSRule.Rules.Azure/issues/546)
    - Check Front Door uses a dedicated health probe path backend pools. [#547](https://github.com/Azure/PSRule.Rules.Azure/issues/547)
    - Check Front Door uses HEAD requests for backend health probes. [#613](https://github.com/Azure/PSRule.Rules.Azure/issues/613)
  - Service Fabric:
    - Check Service Fabric clusters use AAD client authentication. [#619](https://github.com/Azure/PSRule.Rules.Azure/issues/619)
- Updated rules:
  - Azure Kubernetes Service:
    - Updated `Azure.AKS.Version` to 1.19.6. [#603](https://github.com/Azure/PSRule.Rules.Azure/issues/603)
- General improvements:
  - Renamed `Export-AzTemplateRuleData` to `Export-AzRuleTemplateData`. [#596](https://github.com/Azure/PSRule.Rules.Azure/issues/596)
    - New name `Export-AzRuleTemplateData` aligns with prefix of other cmdlets.
    - Use of `Export-AzTemplateRuleData` is now deprecated and will be removed in the next major version.
    - Added alias to allow `Export-AzTemplateRuleData` to continue to be used.
    - Using `Export-AzTemplateRuleData` returns a deprecation warning.
  - Added support for `environment` template function. [#517](https://github.com/Azure/PSRule.Rules.Azure/issues/517)
- Engineering:
  - Bump PSRule dependency to v1.0.1. [#611](https://github.com/Azure/PSRule.Rules.Azure/issues/611)

What's changed since pre-release v1.0.0-B2101028:

- No additional changes.

## v1.0.0-B2101028 (pre-release)

What's changed since pre-release v1.0.0-B2101016:

- New rules:
  - All resources:
    - Check parameter default value type matches type. [#311](https://github.com/Azure/PSRule.Rules.Azure/issues/311)
- General improvements:
  - Renamed `Export-AzTemplateRuleData` to `Export-AzRuleTemplateData`. [#596](https://github.com/Azure/PSRule.Rules.Azure/issues/596)
    - New name `Export-AzRuleTemplateData` aligns with prefix of other cmdlets.
    - Use of `Export-AzTemplateRuleData` is now deprecated and will be removed in the next major version.
    - Added alias to allow `Export-AzTemplateRuleData` to continue to be used.
    - Using `Export-AzTemplateRuleData` returns a deprecation warning.

## v1.0.0-B2101016 (pre-release)

What's changed since pre-release v1.0.0-B2101006:

- New rules:
  - Service Fabric:
    - Check Service Fabric clusters use AAD client authentication. [#619](https://github.com/Azure/PSRule.Rules.Azure/issues/619)
- Bug fixes:
  - Fixed reason `Azure.FrontDoor.ProbePath` so the probe name is included. [#617](https://github.com/Azure/PSRule.Rules.Azure/issues/617)

## v1.0.0-B2101006 (pre-release)

What's changed since v0.19.0:

- New rules:
  - All resources:
    - Check location parameter defaults to resource group. [#361](https://github.com/Azure/PSRule.Rules.Azure/issues/361)
  - Front Door:
    - Check Front Door uses a health probe for each backend pool. [#546](https://github.com/Azure/PSRule.Rules.Azure/issues/546)
    - Check Front Door uses a dedicated health probe path backend pools. [#547](https://github.com/Azure/PSRule.Rules.Azure/issues/547)
    - Check Front Door uses HEAD requests for backend health probes. [#613](https://github.com/Azure/PSRule.Rules.Azure/issues/613)
- Updated rules:
  - Azure Kubernetes Service:
    - Updated `Azure.AKS.Version` to 1.19.6. [#603](https://github.com/Azure/PSRule.Rules.Azure/issues/603)
- General improvements:
  - Added support for `environment` template function. [#517](https://github.com/Azure/PSRule.Rules.Azure/issues/517)
- Engineering:
  - Bump PSRule dependency to v1.0.1. [#611](https://github.com/Azure/PSRule.Rules.Azure/issues/611)

[troubleshooting guide]: troubleshooting.md
