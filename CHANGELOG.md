# Change log

## Unreleased

## v0.10.0-B2003032 (pre-release)

- Fixed unused VM resource false positives in templates. [#312](https://github.com/Microsoft/PSRule.Rules.Azure/issues/312)
- Fixed handling SKU for accelerated networking. [#314](https://github.com/Microsoft/PSRule.Rules.Azure/issues/314)
- Fixed detection of hybrid use benefit in templates. [#313](https://github.com/Microsoft/PSRule.Rules.Azure/issues/313)
- Fixed exception message when a template or parameter file is not found. [#316](https://github.com/Microsoft/PSRule.Rules.Azure/issues/316)

## v0.10.0-B2003004 (pre-release)

- Fixed detection of diagnostic logging for Front Door. [#307](https://github.com/Microsoft/PSRule.Rules.Azure/issues/307)
- Fixed Front Door WAF Policy export. [#308](https://github.com/Microsoft/PSRule.Rules.Azure/issues/308)

## v0.10.0-B2002023 (pre-release)

- Improvements to verbose logging of `Export-AzRuleData`. [#301](https://github.com/Microsoft/PSRule.Rules.Azure/issues/301)
- Fixed union of object properties in templates. [#303](https://github.com/Microsoft/PSRule.Rules.Azure/issues/303)

## v0.9.0

What's changed since v0.8.0:

- New rules:
  - Azure Firewall:
    - Check threat intelligence is configured as deny. [#266](https://github.com/Microsoft/PSRule.Rules.Azure/issues/266)
  - Front Door:
    - Check Front Door is enabled. [#267](https://github.com/Microsoft/PSRule.Rules.Azure/issues/267)
    - Check Front Door uses TLS 1.2. [#268](https://github.com/Microsoft/PSRule.Rules.Azure/issues/268)
    - Check Front Door has a configured WAF policy. [#269](https://github.com/Microsoft/PSRule.Rules.Azure/issues/269)
    - Check Front Door WAF policy is configured in prevention mode. [#271](https://github.com/Microsoft/PSRule.Rules.Azure/issues/271)
    - Check Front Door WAF policy is enabled. [#270](https://github.com/Microsoft/PSRule.Rules.Azure/issues/270)
    - Check if diagnostic logs are configured. [#289](https://github.com/Microsoft/PSRule.Rules.Azure/issues/289)
  - Traffic Manager:
    - Check web-based endpoints are monitored with HTTPS. [#240](https://github.com/Microsoft/PSRule.Rules.Azure/issues/240)
    - Check at least two endpoints are enabled. [#241](https://github.com/Microsoft/PSRule.Rules.Azure/issues/241)
  - Key Vault:
    - Check soft delete is enabled. [#277](https://github.com/Microsoft/PSRule.Rules.Azure/issues/277)
    - Check purge protection is enabled. [#280](https://github.com/Microsoft/PSRule.Rules.Azure/issues/280)
    - Check least privileges permissions assigned in access policy. [#281](https://github.com/Microsoft/PSRule.Rules.Azure/issues/281)
    - Check if diagnostic logs are configured. [#288](https://github.com/Microsoft/PSRule.Rules.Azure/issues/288)
  - Subscriptions:
    - Check if service health alerts are configured. [#290](https://github.com/Microsoft/PSRule.Rules.Azure/issues/290)
- Updated rules:
  - Exclude cloud shell storage accounts from data rules. [#278](https://github.com/Microsoft/PSRule.Rules.Azure/issues/278)
    - `Azure.Storage.UseReplication` and `Azure.Storage.SoftDelete` ignore cloud shell storage accounts.
- General improvements:
  - Removed module dependency on `Az.Security`. [#105](https://github.com/Microsoft/PSRule.Rules.Azure/issues/105)
- Bug fixes:
  - Fixed incorrect string formatting in POSIX culture.  [#262](https://github.com/Microsoft/PSRule.Rules.Azure/issues/262)
  - Fixed `Azure.VNET.UseNSGs` to exclude `AzureFirewallSubnet`. [#261](https://github.com/Microsoft/PSRule.Rules.Azure/issues/261)

What's changed since pre-release v0.9.0-B2002036:

- No additional changes.

## v0.9.0-B2002036 (pre-release)

- Exclude cloud shell storage accounts from data rules. [#278](https://github.com/Microsoft/PSRule.Rules.Azure/issues/278)
- Added new rule for Subscriptions:
  - Check if service health alerts are configured. [#290](https://github.com/Microsoft/PSRule.Rules.Azure/issues/290)
- Added new rule for Key Vault:
  - Check if diagnostic logs are configured. [#288](https://github.com/Microsoft/PSRule.Rules.Azure/issues/288)
- Added new rule for Front Door:
  - Check if diagnostic logs are configured. [#289](https://github.com/Microsoft/PSRule.Rules.Azure/issues/289)
- Removed module dependency on `Az.Security`. [#105](https://github.com/Microsoft/PSRule.Rules.Azure/issues/105)

## v0.9.0-B2002026 (pre-release)

- Added new rules for Traffic Manager:
  - Check web-based endpoints are monitored with HTTPS. [#240](https://github.com/Microsoft/PSRule.Rules.Azure/issues/240)
  - Check at least two endpoints are enabled. [#241](https://github.com/Microsoft/PSRule.Rules.Azure/issues/241)
- Added new rules for Key Vault:
  - Check soft delete is enabled. [#277](https://github.com/Microsoft/PSRule.Rules.Azure/issues/277)
  - Check purge protection is enabled. [#280](https://github.com/Microsoft/PSRule.Rules.Azure/issues/280)
  - Check least privileges permissions assigned in access policy. [#281](https://github.com/Microsoft/PSRule.Rules.Azure/issues/281)

## v0.9.0-B2002019 (pre-release)

- Added new rule to check Azure Firewall threat intelligence is configured as deny. [#266](https://github.com/Microsoft/PSRule.Rules.Azure/issues/266)
- Added new rules for Front Door:
  - Check Front Door is enabled. [#267](https://github.com/Microsoft/PSRule.Rules.Azure/issues/267)
  - Check Front Door uses TLS 1.2. [#268](https://github.com/Microsoft/PSRule.Rules.Azure/issues/268)
  - Check Front Door has a configured WAF policy. [#269](https://github.com/Microsoft/PSRule.Rules.Azure/issues/269)
  - Check Front Door WAF policy is configured in prevention mode. [#271](https://github.com/Microsoft/PSRule.Rules.Azure/issues/271)
  - Check Front Door WAF policy is enabled. [#270](https://github.com/Microsoft/PSRule.Rules.Azure/issues/270)

## v0.9.0-B2002011 (pre-release)

- Fixed incorrect string formatting in POSIX culture.  [#262](https://github.com/Microsoft/PSRule.Rules.Azure/issues/262)
- Fixed `Azure.VNET.UseNSGs` to exclude `AzureFirewallSubnet`. [#261](https://github.com/Microsoft/PSRule.Rules.Azure/issues/261)

## v0.8.0

What's changed since v0.7.0:

- New rules:
  - API Management:
    - Check API Management uses secure protocol versions. [#237](https://github.com/Microsoft/PSRule.Rules.Azure/issues/237)
    - Check API Management published APIs use HTTPS. [#236](https://github.com/Microsoft/PSRule.Rules.Azure/issues/236)
    - Check API Management backend connections use HTTPS. [#238](https://github.com/Microsoft/PSRule.Rules.Azure/issues/238)
    - Check API Management named values are encrypted. [#239](https://github.com/Microsoft/PSRule.Rules.Azure/issues/239)
  - Automation Accounts:
    - Check automation accounts use encrypted variables. [#211](https://github.com/Microsoft/PSRule.Rules.Azure/issues/211)
    - Check automation account webhook expiry interval. [#212](https://github.com/Microsoft/PSRule.Rules.Azure/issues/212)
  - CDN:
    - Check Azure CDN connections use HTTPS. [#242](https://github.com/Microsoft/PSRule.Rules.Azure/issues/242)
  - Resource Manager Templates:
    - Check ARM template and parameter file structure. [#225](https://github.com/Microsoft/PSRule.Rules.Azure/issues/225)
- Updated rules:
  - Azure Kubernetes Service:
    - Updated `Azure.AKS.Version` to 1.15.7. [#247](https://github.com/Microsoft/PSRule.Rules.Azure/issues/247)
  - Virtual networks:
    - Updated `Azure.VNET.UseNSGs` to apply to subnet resources from templates. [#246](https://github.com/Microsoft/PSRule.Rules.Azure/issues/246)
- General improvements:
  - Improvements to rule help wording and usage of links section. [#220](https://github.com/Microsoft/PSRule.Rules.Azure/issues/220) [#224](https://github.com/Microsoft/PSRule.Rules.Azure/issues/224) [#257](https://github.com/Microsoft/PSRule.Rules.Azure/issues/257)
    - Documentation and reasons messages are now available for all `en` cultures.
  - Various updates to rule implementation to take advantage of PSRule v0.12.0 language features. [#220](https://github.com/Microsoft/PSRule.Rules.Azure/issues/220)
  - **Breaking change**: Shorten rule names to improve output display. [#119](https://github.com/Microsoft/PSRule.Rules.Azure/issues/119)
    - Application Gateway rules have been renamed from `Azure.VirtualNetwork.*` to `Azure.AppGW.*`.
    - Load balancer rules have been renamed from `Azure.VirtualNetwork.*` to `Azure.LB.*`.
    - NSG rules have been renamed from `Azure.VirtualNetwork.*` to `Azure.NSG.*`.
    - VNET rules have been renamed from `Azure.VirtualNetwork.*` to `Azure.VNET.*`.
    - NIC rules have been renamed from `Azure.VirtualNetwork.*` to `Azure.VM.*`.
    - Renamed storage account rule `Azure.Storage.SecureTransferRequired` to `Azure.Storage.SecureTransfer`.
- Bug fixes:
  - Fix `Azure.Resource.UseTags` applying to template and parameter files. [#230](https://github.com/Microsoft/PSRule.Rules.Azure/issues/230)

What's changed since pre-release v0.8.0-B2001029:

- Fixed `Azure.VNET.UseNSGs` not populating subnet name in reason message. [#256](https://github.com/Microsoft/PSRule.Rules.Azure/issues/256)
- Updated reason strings to use parent culture `en`. [#257](https://github.com/Microsoft/PSRule.Rules.Azure/issues/257)

## v0.8.0-B2001029 (pre-release)

- Updated `Azure.VNET.UseNSGs` to apply to subnet resources from templates. [#246](https://github.com/Microsoft/PSRule.Rules.Azure/issues/246)
- Updated `Azure.AKS.Version` to 1.15.7. [#247](https://github.com/Microsoft/PSRule.Rules.Azure/issues/247)
- **Breaking change**: Renamed `Azure.File.*` rules to `Azure.Template.*`. [#252](https://github.com/Microsoft/PSRule.Rules.Azure/issues/252)

## v0.8.0-B2001018 (pre-release)

- Fix `Azure.Resource.UseTags` applying to template and parameter files. [#230](https://github.com/Microsoft/PSRule.Rules.Azure/issues/230)
- Fix ARM template and parameter schemas used to detect files. [#234](https://github.com/Microsoft/PSRule.Rules.Azure/issues/234)
- Added new rule to check API Management uses secure protocol versions. [#237](https://github.com/Microsoft/PSRule.Rules.Azure/issues/237)
- Added new rule to check API Management published APIs use HTTPS. [#236](https://github.com/Microsoft/PSRule.Rules.Azure/issues/236)
- Added new rule to check API Management backend connections use HTTPS. [#238](https://github.com/Microsoft/PSRule.Rules.Azure/issues/238)
- Added new rule to check API Management named values are encrypted. [#239](https://github.com/Microsoft/PSRule.Rules.Azure/issues/239)
- Added new rule to check Azure CDN connections use HTTPS. [#242](https://github.com/Microsoft/PSRule.Rules.Azure/issues/242)

## v0.8.0-B2001006 (pre-release)

- Updated documentation to use parent culture `en`. [#224](https://github.com/Microsoft/PSRule.Rules.Azure/issues/224)
- Added rules for ARM template and parameter file structure. [#225](https://github.com/Microsoft/PSRule.Rules.Azure/issues/225)
- **Breaking change**: Application Gateway rules have been renamed from `Azure.VirtualNetwork.*` to `Azure.AppGW.*`. [#119](https://github.com/Microsoft/PSRule.Rules.Azure/issues/119)
- **Breaking change**: Load balancer rules have been renamed from `Azure.VirtualNetwork.*` to `Azure.LB.*`. [#119](https://github.com/Microsoft/PSRule.Rules.Azure/issues/119)
- **Breaking change**: NSG rules have been renamed from `Azure.VirtualNetwork.*` to `Azure.NSG.*`. [#119](https://github.com/Microsoft/PSRule.Rules.Azure/issues/119)
- **Breaking change**: VNET rules have been renamed from `Azure.VirtualNetwork.*` to `Azure.VNET.*`. [#119](https://github.com/Microsoft/PSRule.Rules.Azure/issues/119)
- **Breaking change**: NIC rules have been renamed from `Azure.VirtualNetwork.*` to `Azure.VM.*`. [#119](https://github.com/Microsoft/PSRule.Rules.Azure/issues/119)
- **Breaking change**: Renamed storage account rule `Azure.Storage.SecureTransferRequired` to `Azure.Storage.SecureTransfer`. [#119](https://github.com/Microsoft/PSRule.Rules.Azure/issues/119)

## v0.8.0-B1912026 (pre-release)

- Fixed Automation account handling with no webhooks or variables. [#219](https://github.com/Microsoft/PSRule.Rules.Azure/issues/219)
- Rule improvements from PSRule v0.12.0. [#220](https://github.com/Microsoft/PSRule.Rules.Azure/issues/220)
- Updated `Azure.AKS.Version` to 1.15.5. [#217](https://github.com/Microsoft/PSRule.Rules.Azure/issues/217)

## v0.8.0-B1912012 (pre-release)

- Added new rule to check automation accounts use encrypted variables. [#211](https://github.com/Microsoft/PSRule.Rules.Azure/issues/211)
- Added new rule to check automation account webhook expiry interval. [#212](https://github.com/Microsoft/PSRule.Rules.Azure/issues/212)

## v0.7.0

What's changed since v0.6.0:

- New rules:
  - Role assignment:
    - Check presence of classic Co-Administrators. [#188](https://github.com/Microsoft/PSRule.Rules.Azure/issues/188)
  - Azure Kubernetes Service:
    - Check AKS node pool version matches cluster version. [#186](https://github.com/Microsoft/PSRule.Rules.Azure/issues/186)
    - Check AKS clusters use pod security policies. [#142](https://github.com/Microsoft/PSRule.Rules.Azure/issues/142)
    - Check AKS clusters use network policies. [#143](https://github.com/Microsoft/PSRule.Rules.Azure/issues/143)
    - Check AKS node pools use scale sets. [#187](https://github.com/Microsoft/PSRule.Rules.Azure/issues/187)
- Updated rules:
  - Azure Kubernetes Service:
    - Updated `Azure.AKS.Version` to check for node pool version. [#191](https://github.com/Microsoft/PSRule.Rules.Azure/issues/191)
- General improvements:
  - Added custom bindings for common resource properties. [#202](https://github.com/Microsoft/PSRule.Rules.Azure/issues/202)
  - Added new baseline to include rules for preview features. [#190](https://github.com/Microsoft/PSRule.Rules.Azure/issues/190)
  - **Breaking change**: Shorten rule names to improve output display. [#119](https://github.com/Microsoft/PSRule.Rules.Azure/issues/119)
    - RBAC rules have been renamed from `Azure.Subscription.*` to `Azure.RBAC.*`.
    - Security Center rules have been renamed from `Azure.Subscription.*` to `Azure.SecureCenter.*`.
  - **Breaking change**: Renamed default baseline from `Azure.SubscriptionDefault` to `Azure.Default`. [#190](https://github.com/Microsoft/PSRule.Rules.Azure/issues/190)
- Bug fixes:
  - Fixed handling of tags for sub-resources. [#203](https://github.com/Microsoft/PSRule.Rules.Azure/issues/203)
  - Fixed missing cmdlet help. [#196](https://github.com/Microsoft/PSRule.Rules.Azure/issues/196)
  - Fixed AKS templates without node pool orchestratorVersion fail. [#198](https://github.com/Microsoft/PSRule.Rules.Azure/issues/198)
  - Fixed null reference without parameters file. [#189](https://github.com/Microsoft/PSRule.Rules.Azure/issues/189)

What's changed since pre-release v0.7.0-B1912024:

- No additional changes.

## v0.7.0-B1912024 (pre-release)

- Fixed handling of tags for sub-resources. [#203](https://github.com/Microsoft/PSRule.Rules.Azure/issues/203)
- Added custom bindings for common resource properties. [#202](https://github.com/Microsoft/PSRule.Rules.Azure/issues/202)

## v0.7.0-B1912017 (pre-release)

- Fixed missing cmdlet help. [#196](https://github.com/Microsoft/PSRule.Rules.Azure/issues/196)
- Fixed AKS templates without node pool orchestratorVersion fail. [#198](https://github.com/Microsoft/PSRule.Rules.Azure/issues/198)

## v0.7.0-B1912008 (pre-release)

- Fixed null reference without parameters file. [#189](https://github.com/Microsoft/PSRule.Rules.Azure/issues/189)
- Added new rule to check presence of classic Co-Administrators. [#188](https://github.com/Microsoft/PSRule.Rules.Azure/issues/188)
- Added new rule to check AKS node pool version matches cluster version. [#186](https://github.com/Microsoft/PSRule.Rules.Azure/issues/186)
- Added new rule to check AKS clusters use pod security policies. [#142](https://github.com/Microsoft/PSRule.Rules.Azure/issues/142)
- Added new rule to check AKS clusters use network policies. [#143](https://github.com/Microsoft/PSRule.Rules.Azure/issues/143)
- Added new rule to check AKS node pools use scale sets. [#187](https://github.com/Microsoft/PSRule.Rules.Azure/issues/187)
- Added new baseline to include rules for preview features. [#190](https://github.com/Microsoft/PSRule.Rules.Azure/issues/190)
- Updated `Azure.AKS.Version` to check for node pool version. [#191](https://github.com/Microsoft/PSRule.Rules.Azure/issues/191)
- **Breaking change**: RBAC rules have been renamed from `Azure.Subscription.*` to `Azure.RBAC.*`. [#119](https://github.com/Microsoft/PSRule.Rules.Azure/issues/119)
- **Breaking change**: Security Center rules have been renamed from `Azure.Subscription.*` to `Azure.SecureCenter.*`. [#119](https://github.com/Microsoft/PSRule.Rules.Azure/issues/119)
- **Breaking change**: Renamed default baseline from `Azure.SubscriptionDefault` to `Azure.Default`. [#190](https://github.com/Microsoft/PSRule.Rules.Azure/issues/190)

## v0.6.0

What's changed since v0.5.0:

- New features:
  - Added support for exporting rule data from templates. [#145](https://github.com/Microsoft/PSRule.Rules.Azure/issues/145)
    - Added `Export-AzTemplateRuleData` cmdlet to export templates. See cmdlet help for limitations.
    - Template and parameters are merged, resolving functions, copy loops and conditions.
- Updated rules:
  - Azure Kubernetes Services:
    - Updated `Azure.AKS.Version` to 1.14.8. [#140](https://github.com/Microsoft/PSRule.Rules.Azure/issues/140)
- General improvements:
  - Updated rules to use type pre-conditions. [#144](https://github.com/Microsoft/PSRule.Rules.Azure/issues/144)
- Bug fixes:
  - Fixed processing of `Azure.Resource.UseTags` to exclude `*/providers/roleAssignments`. [#155](https://github.com/Microsoft/PSRule.Rules.Azure/issues/155)
    - Provider role assignments do not support tags.
  - Fixed processing of `Azure.Resource.AllowedRegions`. [#156](https://github.com/Microsoft/PSRule.Rules.Azure/issues/156)
    - Exclude `*/providers/roleAssignments`, `Microsoft.Authorization/*` and `Microsoft.Consumption/*`.
  - Fixed processing of `Azure.VirtualNetwork.NSGAssociated` for templates. [#150](https://github.com/Microsoft/PSRule.Rules.Azure/issues/150)
  - Fixed processing of `Azure.VirtualNetwork.LateralTraversal` when `destinationPortRanges` is used. [#149](https://github.com/Microsoft/PSRule.Rules.Azure/issues/149)

What's changed since pre-release v0.6.0-B1911046:

- No additional changes.

## v0.6.0-B1911046 (pre-release)

- Improved template support of `Export-AzTemplateRuleData` cmdlet. [#145](https://github.com/Microsoft/PSRule.Rules.Azure/issues/145)
  - Added support for `deployment` function.
  - Fixed property copy loop.
- Fixed `Export-AzTemplateRuleData` does not return FileInfo objects. [#162](https://github.com/Microsoft/PSRule.Rules.Azure/issues/162)
- Fixed automatically name outputs from `Export-AzTemplateRuleData`. [#163](https://github.com/Microsoft/PSRule.Rules.Azure/issues/163)
- Fixed resource segmentation issue when ResourceType includes trailing slash. [#165](https://github.com/Microsoft/PSRule.Rules.Azure/issues/165)
- Fixed expand resource template property as null fails. [#167](https://github.com/Microsoft/PSRule.Rules.Azure/issues/167)
- Fixed case-sensitivity of variables, parameters and functions. [#168](https://github.com/Microsoft/PSRule.Rules.Azure/issues/168)
- Fixed out of order parameter and variables cross reference. [#170](https://github.com/Microsoft/PSRule.Rules.Azure/issues/170)
- Fixed expression parser race condition. [#171](https://github.com/Microsoft/PSRule.Rules.Azure/issues/171)
- Fixed handling of padding spaces in expressions. [#173](https://github.com/Microsoft/PSRule.Rules.Azure/issues/173)
- Fixed property of property is parsed incorrectly. [#174](https://github.com/Microsoft/PSRule.Rules.Azure/issues/174)
- Fixed root variable copy loop handling. [#175](https://github.com/Microsoft/PSRule.Rules.Azure/issues/175)

## v0.6.0-B1911027 (pre-release)

- Fixed processing of `Azure.Resource.UseTags` to exclude `*/providers/roleAssignments`. [#155](https://github.com/Microsoft/PSRule.Rules.Azure/issues/155)
  - Provider role assignments do not support tags.
- Fixed processing of `Azure.Resource.AllowedRegions`. [#156](https://github.com/Microsoft/PSRule.Rules.Azure/issues/156)
  - Exclude `*/providers/roleAssignments`, `Microsoft.Authorization/*` and `Microsoft.Consumption/*`.

## v0.6.0-B1911020 (pre-release)

- Fixed processing of `Azure.VirtualNetwork.NSGAssociated` for templates. [#150](https://github.com/Microsoft/PSRule.Rules.Azure/issues/150)
- Fixed processing of `Azure.VirtualNetwork.LateralTraversal` when `destinationPortRanges` is used. [#149](https://github.com/Microsoft/PSRule.Rules.Azure/issues/149)
- Improved template support of `Export-AzTemplateRuleData` cmdlet. [#145](https://github.com/Microsoft/PSRule.Rules.Azure/issues/145)
  - Added support for nested templates.
  - Added support for `array`, `createArray`, `coalesce`, `intersection`, `dataUri` and `dataUriToString` functions.

## v0.6.0-B1911011 (pre-release)

- Updated `Azure.AKS.Version` to 1.14.8. [#140](https://github.com/Microsoft/PSRule.Rules.Azure/issues/140)
- Updated rules to use type pre-conditions. [#144](https://github.com/Microsoft/PSRule.Rules.Azure/issues/144)
- **Experimental**: Added support for exporting rule data from templates. [#145](https://github.com/Microsoft/PSRule.Rules.Azure/issues/145)
  - Added `Export-AzTemplateRuleData` cmdlet to export templates. See cmdlet help for limitations.
  - Template and parameters are merged, resolving functions, copy loops and conditions.

## v0.5.0

What's changed since v0.4.0:

- New rules:
  - Virtual machines:
    - Check Windows automatic updates are enabled. [#132](https://github.com/Microsoft/PSRule.Rules.Azure/issues/132)
    - Check VM agent is automatically provisioned. [#131](https://github.com/Microsoft/PSRule.Rules.Azure/issues/131)
- Updated rules:
  - Azure Kubernetes Services:
    - Updated `Azure.AKS.Version` to 1.14.6. [#130](https://github.com/Microsoft/PSRule.Rules.Azure/issues/130)
- General improvements:
  - Shorten rule names for virtual machined to `Azure.VM.*` to improve output display. [#119](https://github.com/Microsoft/PSRule.Rules.Azure/issues/119)
    - **Breaking change**: Rules have been renamed from `Azure.VirtualMachine.*` to `Azure.VM.*`.

What's changed since pre-release v0.5.0-B1910004:

- No additional changes.

## v0.5.0-B1910004 (pre-release)

- Added rule to verify Windows automatic updates are enabled. [#132](https://github.com/Microsoft/PSRule.Rules.Azure/issues/132)
- Added rule to verify VM agent is automatically provisioned. [#131](https://github.com/Microsoft/PSRule.Rules.Azure/issues/131)
- Updated `Azure.AKS.Version` to 1.14.6. [#130](https://github.com/Microsoft/PSRule.Rules.Azure/issues/130)
- **Breaking change**: Renamed `Azure.VirtualMachine.*` rules to `Azure.VM.*`. [#119](https://github.com/Microsoft/PSRule.Rules.Azure/issues/119)

## v0.4.0

What's changed since v0.3.0:

- New rules:
  - Virtual machines:
    - Added rule to verify Azure Disk Encryption. [#122](https://github.com/Microsoft/PSRule.Rules.Azure/issues/122)
    - Added rule to check if public key is used for Linux. [#123](https://github.com/Microsoft/PSRule.Rules.Azure/issues/123)
  - Virtual networking:
    - Added rule to verify connectivity of VNET peers. [#120](https://github.com/Microsoft/PSRule.Rules.Azure/issues/120)
    - Added rule to check configuration of HTTP/ HTTPS load balancer probes. [#121](https://github.com/Microsoft/PSRule.Rules.Azure/issues/121)
- General improvements:
  - Removed dependency on Az.Storage module. [#105](https://github.com/Microsoft/PSRule.Rules.Azure/issues/105)
  - Added default baseline to module. [#126](https://github.com/Microsoft/PSRule.Rules.Azure/issues/126)

What's changed since pre-release v0.4.0-B190902:

- Added default baseline to module. [#126](https://github.com/Microsoft/PSRule.Rules.Azure/issues/126)

## v0.4.0-B190902 (pre-release)

- Added rule to verify connectivity of VNET peers. [#120](https://github.com/Microsoft/PSRule.Rules.Azure/issues/120)
- Added rule to check configuration of HTTP/ HTTPS load balancer probes. [#121](https://github.com/Microsoft/PSRule.Rules.Azure/issues/121)
- Added rule to verify Azure Disk Encryption. [#122](https://github.com/Microsoft/PSRule.Rules.Azure/issues/122)
- Added rule to check if public key is used for Linux. [#123](https://github.com/Microsoft/PSRule.Rules.Azure/issues/123)
- Removed dependency on Az.Storage module. [#105](https://github.com/Microsoft/PSRule.Rules.Azure/issues/105)

## v0.3.0

What's changed since v0.2.0:

- New rules:
  - App Services:
    - Enforce minimum TLS version for App Service. [#99](https://github.com/Microsoft/PSRule.Rules.Azure/issues/99)
  - Resource clean up:
    - Network security groups that are not associated. [#93](https://github.com/Microsoft/PSRule.Rules.Azure/issues/93)
    - Unattached network interfaces. [#92](https://github.com/Microsoft/PSRule.Rules.Azure/issues/92)
  - Role assignment:
    - Added subscription RBAC delegation rules. [#107](https://github.com/Microsoft/PSRule.Rules.Azure/issues/107)
      - Check for number of subscription owners.
      - Check for RBAC inheritance from management groups.
      - Check for user RBAC assignments.
      - Check for RBAC delegation on individual resources.
  - Virtual machines:
    - VMs should avoid using expired promo SKUs. [#87](https://github.com/Microsoft/PSRule.Rules.Azure/issues/87)
    - VMs should avoid using basic SKUs. [#69](https://github.com/Microsoft/PSRule.Rules.Azure/issues/69)
  - Virtual networking:
    - Added NSG rule to check for lateral traversal security rules. [#103](https://github.com/Microsoft/PSRule.Rules.Azure/issues/103)
    - Added rule to detect deny all inbound NSG rule. [#94](https://github.com/Microsoft/PSRule.Rules.Azure/issues/94)
- Updated rules:
  - App Services:
    - Updated App Service site rules to include slots. [#100](https://github.com/Microsoft/PSRule.Rules.Azure/issues/100)
    - `Azure.AppService.ARRAffinity` and `Azure.AppService.UseHTTPS` now run against slots.
  - Azure Kubernetes Services:
    - Updated `Azure.AKS.Version` to 1.14.5. [#109](https://github.com/Microsoft/PSRule.Rules.Azure/issues/109)
- Bug fixes:
  - Fix handling of empty DNS servers in `Azure.VirtualNetwork.LocalDNS`. [#84](https://github.com/Microsoft/PSRule.Rules.Azure/issues/84)
  - Fix handling of no peering connections in `Azure.VirtualNetwork.LocalDNS`. [#89](https://github.com/Microsoft/PSRule.Rules.Azure/issues/89)
  - Fix export of additional properties for `Microsoft.Sql/servers`. [#114](https://github.com/Microsoft/PSRule.Rules.Azure/issues/114)
  - Excluded global services from Azure.Resource.AllowedRegions. [#96](https://github.com/Microsoft/PSRule.Rules.Azure/issues/96)

What's changed since pre-release v0.3.0-B190807:

- Fix export of additional properties for `Microsoft.Sql/servers`. [#114](https://github.com/Microsoft/PSRule.Rules.Azure/issues/114)

## v0.3.0-B190807 (pre-release)

- Updated `Azure.AKS.Version` to 1.14.5. [#109](https://github.com/Microsoft/PSRule.Rules.Azure/issues/109)
- Added subscription RBAC delegation rules. [#107](https://github.com/Microsoft/PSRule.Rules.Azure/issues/107)
  - Check for number of subscription owners.
  - Check for RBAC inheritance from management groups.
  - Check for user RBAC assignments.
  - Check for RBAC delegation on individual resources.

## v0.3.0-B190723 (pre-release)

- Excluded global services from Azure.Resource.AllowedRegions. [#96](https://github.com/Microsoft/PSRule.Rules.Azure/issues/96)
- Enforce minimum TLS version for App Service. [#99](https://github.com/Microsoft/PSRule.Rules.Azure/issues/99)
- Updated App Service site rules to include slots. [#100](https://github.com/Microsoft/PSRule.Rules.Azure/issues/100)
  - `Azure.AppService.ARRAffinity` and `Azure.AppService.UseHTTPS` now run against slots.
- Added rule to detect deny all inbound NSG rule. [#94](https://github.com/Microsoft/PSRule.Rules.Azure/issues/94)
- Added unused resource rules.
  - Network security groups that are not associated. [#93](https://github.com/Microsoft/PSRule.Rules.Azure/issues/93)
  - Unattached network interfaces. [#92](https://github.com/Microsoft/PSRule.Rules.Azure/issues/92)
- Added NSG rule to check for lateral traversal security rules. [#103](https://github.com/Microsoft/PSRule.Rules.Azure/issues/103)

## v0.3.0-B190710 (pre-release)

- Fix handling of empty DNS servers in `Azure.VirtualNetwork.LocalDNS`. [#84](https://github.com/Microsoft/PSRule.Rules.Azure/issues/84)
- Fix handling of no peering connections in `Azure.VirtualNetwork.LocalDNS`. [#89](https://github.com/Microsoft/PSRule.Rules.Azure/issues/89)
- Updated AKS version in `Azure.AKS.Version` to 1.13.7. [#83](https://github.com/Microsoft/PSRule.Rules.Azure/issues/83)
- Added VM SKU rules:
  - VMs should avoid using expired promo SKUs. [#87](https://github.com/Microsoft/PSRule.Rules.Azure/issues/87)
  - VMs should avoid using basic SKUs. [#69](https://github.com/Microsoft/PSRule.Rules.Azure/issues/69)

## v0.2.0

What's changed since v0.1.0:

- Fix rule `Azure.AKS.UseRBAC` returns null. [#60](https://github.com/Microsoft/PSRule.Rules.Azure/issues/60)
- Fix rule `Azure.Storage.SoftDelete` and `Azure.Storage.SecureTransferRequired` returns null. [#64](https://github.com/Microsoft/PSRule.Rules.Azure/issues/64)
- Fix collection of ASR vault configuration for cmdlet deprecation. [#63](https://github.com/Microsoft/PSRule.Rules.Azure/issues/63)
- Updated rules to use `Recommend` keyword instead of `Hint` alias. [#71](https://github.com/Microsoft/PSRule.Rules.Azure/issues/71)
- Added SQL firewall rule range check to determine an excessive number of permitted IP addresses. [#3](https://github.com/Microsoft/PSRule.Rules.Azure/issues/3) [#10](https://github.com/Microsoft/PSRule.Rules.Azure/issues/10) [#54](https://github.com/Microsoft/PSRule.Rules.Azure/issues/54)
  - The rules `Azure.SQL.FirewallIPRange`, `Azure.MySQL.FirewallIPRange` and `Azure.PostgreSQL.FirewallIPRange` were added to check SQL, MySQL and PostgreSQL.
- Added parameters to filter resource export by resource group and/ or tag. [#59](https://github.com/Microsoft/PSRule.Rules.Azure/issues/59)
  - Added `-ResourceGroupName` and `-Tag` parameters to `Export-AzRuleData` cmdlet.
- Added support for Application Gateway v2. [#75](https://github.com/Microsoft/PSRule.Rules.Azure/issues/75)
- Added VNET rule to check for local DNS. [#68](https://github.com/Microsoft/PSRule.Rules.Azure/issues/68)
- Added WAF hardening rules for Application Gateway. [#78](https://github.com/Microsoft/PSRule.Rules.Azure/issues/78)
  - Application Gateways use OWASP 3.x rules.
  - Application Gateways have WAF enabled.
  - Application Gateways have all OWASP rules enabled.

What's changed since pre-release v0.2.0-B190715:

- No additional changes.

## v0.2.0-B190715 (pre-release)

- Added support for Application Gateway v2. [#75](https://github.com/Microsoft/PSRule.Rules.Azure/issues/75)
- Added VNET rule to check for local DNS. [#68](https://github.com/Microsoft/PSRule.Rules.Azure/issues/68)
- Added WAF hardening rules for Application Gateway. [#78](https://github.com/Microsoft/PSRule.Rules.Azure/issues/78)
  - Application Gateways use OWASP 3.x rules.
  - Application Gateways have WAF enabled.
  - Application Gateways have all OWASP rules enabled.

## v0.2.0-B190706 (pre-release)

- Fix rule `Azure.AKS.UseRBAC` returns null. [#60](https://github.com/Microsoft/PSRule.Rules.Azure/issues/60)
- Fix rule `Azure.Storage.SoftDelete` and `Azure.Storage.SecureTransferRequired` returns null. [#64](https://github.com/Microsoft/PSRule.Rules.Azure/issues/64)
- Fix collection of ASR vault configuration for cmdlet deprecation. [#63](https://github.com/Microsoft/PSRule.Rules.Azure/issues/63)
- Added SQL firewall rule range check to determine an excessive number of permitted IP addresses. [#3](https://github.com/Microsoft/PSRule.Rules.Azure/issues/3) [#10](https://github.com/Microsoft/PSRule.Rules.Azure/issues/10) [#54](https://github.com/Microsoft/PSRule.Rules.Azure/issues/54)
  - The rules `Azure.SQL.FirewallIPRange`, `Azure.MySQL.FirewallIPRange` and `Azure.PostgreSQL.FirewallIPRange` were added to check SQL, MySQL and PostgreSQL.
- Updated rules to use `Recommend` keyword instead of `Hint` alias. [#71](https://github.com/Microsoft/PSRule.Rules.Azure/issues/71)
- Added parameters to filter resource export by resource group and/ or tag. [#59](https://github.com/Microsoft/PSRule.Rules.Azure/issues/59)
  - Added `-ResourceGroupName` and `-Tag` parameters to `Export-AzRuleData` cmdlet.

## v0.1.0

- Initial release.

What's changed since pre-release v0.1.0-B190624:

- No additional changes.

## v0.1.0-B190624 (pre-release)

- Added rule to check if allow access to Azure services enabled for MySQL. [#4](https://github.com/Microsoft/PSRule.Rules.Azure/issues/4)
- Added rule to count the number of database server firewall rules for MySQL. [#2](https://github.com/Microsoft/PSRule.Rules.Azure/issues/2)
- Added rule to check if allow access to Azure services enabled for PostgreSQL. [#50](https://github.com/Microsoft/PSRule.Rules.Azure/issues/50)
- Added rule to count the number of database server firewall rules for PostgreSQL. [#51](https://github.com/Microsoft/PSRule.Rules.Azure/issues/51)
- Added rule to check if SSL is enforced for PostgreSQL. [#49](https://github.com/Microsoft/PSRule.Rules.Azure/issues/49)

## v0.1.0-B190607 (pre-release)

- Added rule documentation. [#40](https://github.com/Microsoft/PSRule.Rules.Azure/issues/40)

## v0.1.0-B190569 (pre-release)

- Fix exported resource data overwritten. [#34](https://github.com/Microsoft/PSRule.Rules.Azure/issues/34)

## v0.1.0-B190562 (pre-release)

- Add units tests for `Export-AzRuleData` and update filters. [#28](https://github.com/Microsoft/PSRule.Rules.Azure/issues/28)
- `Export-AzRuleData` returns files generated by default. [#27](https://github.com/Microsoft/PSRule.Rules.Azure/issues/27)
- `Export-AzRuleData` passes through objects resource objects to the pipeline. [#25](https://github.com/Microsoft/PSRule.Rules.Azure/issues/25)
- **Breaking change** - `Export-AzRuleData` only exports data from current subscription context by default. [#24](https://github.com/Microsoft/PSRule.Rules.Azure/issues/24)
  - Data can be exported from all subscription contexts by using the `-All` switch, or specifying specific subscriptions with the `-Subscription` or `-Tenant` parameters.

## v0.1.0-B190543 (pre-release)

- Fix cannot find the type for custom attribute error. [#21](https://github.com/Microsoft/PSRule.Rules.Azure/issues/21)

## v0.1.0-B190536 (pre-release)

- Initial pre-release.
