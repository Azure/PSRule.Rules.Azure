# Change log

**Important notes**:

- Issue #741: `Could not load file or assembly YamlDotNet`.
See [troubleshooting guide] for a workaround to this issue.

## Unreleased

What's changed since v1.3.0:

- Engineering:
  - Bump PSRule dependency to v1.3.0. [#749](https://github.com/Microsoft/PSRule.Rules.Azure/issues/749)
  - Bump YamlDotNet dependency to v11.1.1. [#742](https://github.com/Microsoft/PSRule.Rules.Azure/issues/742)

## v1.3.0

What's changed since v1.2.1:

- New rules:
  - Policy:
    - Check policy assignment display name and description are set. [#725](https://github.com/microsoft/PSRule.Rules.Azure/issues/725)
    - Check policy assignment assigned by metadata is set. [#726](https://github.com/microsoft/PSRule.Rules.Azure/issues/726)
    - Check policy exemption display name and description are set. [#723](https://github.com/microsoft/PSRule.Rules.Azure/issues/723)
    - Check policy waiver exemptions have an expiry date set. [#724](https://github.com/microsoft/PSRule.Rules.Azure/issues/724)
- Removed rules:
  - Storage:
    - Remove `Azure.Storage.UseEncryption` as Storage Service Encryption (SSE) is always on. [#630](https://github.com/Microsoft/PSRule.Rules.Azure/issues/630)
      - SSE is on by default and can not be disabled.
- General improvements:
  - Additional metadata added in parameter files is passed through with `Get-AzRuleTemplateLink`. [#706](https://github.com/Microsoft/PSRule.Rules.Azure/issues/706)
  - Improved binding support for File inputs. [#480](https://github.com/microsoft/PSRule.Rules.Azure/issues/480)
    - Template and parameter file names now return a relative path instead of full path.
  - Added API version for each module resource. [#729](https://github.com/microsoft/PSRule.Rules.Azure/issues/729)
- Engineering:
  - Clean up depreciated warning message for configuration option `azureAllowedRegions`. [#737](https://github.com/microsoft/PSRule.Rules.Azure/issues/737)
  - Clean up depreciated warning message for configuration option `minAKSVersion`. [#738](https://github.com/microsoft/PSRule.Rules.Azure/issues/738)
  - Bump PSRule dependency to v1.2.0. [#713](https://github.com/Microsoft/PSRule.Rules.Azure/issues/713)
- Bug fixes:
  - Fixed could not load file or assembly YamlDotNet. [#741](https://github.com/microsoft/PSRule.Rules.Azure/issues/741)
    - This fix pins the PSRule version to v1.2.0 until the next stable release of PSRule for Azure.

What's changed since pre-release v1.3.0-B2104040:

- No additional changes.

## v1.3.0-B2104040 (pre-release)

What's changed since pre-release v1.3.0-B2104034:

- Bug fixes:
  - Fixed could not load file or assembly YamlDotNet. [#741](https://github.com/microsoft/PSRule.Rules.Azure/issues/741)
    - This fix pins the PSRule version to v1.2.0 until the next stable release of PSRule for Azure.

## v1.3.0-B2104034 (pre-release)

What's changed since pre-release v1.3.0-B2104023:

- New rules:
  - Policy:
    - Check policy assignment display name and description are set. [#725](https://github.com/microsoft/PSRule.Rules.Azure/issues/725)
    - Check policy assignment assigned by metadata is set. [#726](https://github.com/microsoft/PSRule.Rules.Azure/issues/726)
    - Check policy exemption display name and description are set. [#723](https://github.com/microsoft/PSRule.Rules.Azure/issues/723)
    - Check policy waiver exemptions have an expiry date set. [#724](https://github.com/microsoft/PSRule.Rules.Azure/issues/724)
- Engineering:
  - Clean up depreciated warning message for configuration option `azureAllowedRegions`. [#737](https://github.com/microsoft/PSRule.Rules.Azure/issues/737)
  - Clean up depreciated warning message for configuration option `minAKSVersion`. [#738](https://github.com/microsoft/PSRule.Rules.Azure/issues/738)

## v1.3.0-B2104023 (pre-release)

What's changed since pre-release v1.3.0-B2104013:

- General improvements:
  - Improved binding support for File inputs. [#480](https://github.com/microsoft/PSRule.Rules.Azure/issues/480)
    - Template and parameter file names now return a relative path instead of full path.
  - Added API version for each module resource. [#729](https://github.com/microsoft/PSRule.Rules.Azure/issues/729)

## v1.3.0-B2104013 (pre-release)

What's changed since pre-release v1.3.0-B2103007:

- Engineering:
  - Bump PSRule dependency to v1.2.0. [#713](https://github.com/Microsoft/PSRule.Rules.Azure/issues/713)
- Bug fixes:
  - Fixed export not expanding nested deployments. [#715](https://github.com/Microsoft/PSRule.Rules.Azure/issues/715)

## v1.3.0-B2103007 (pre-release)

What's changed since v1.2.0:

- Removed rules:
  - Storage:
    - Remove `Azure.Storage.UseEncryption` as Storage Service Encryption (SSE) is always on. [#630](https://github.com/Microsoft/PSRule.Rules.Azure/issues/630)
      - SSE is on by default and can not be disabled.
- General improvements:
  - Additional metadata added in parameter files is passed through with `Get-AzRuleTemplateLink`. [#706](https://github.com/Microsoft/PSRule.Rules.Azure/issues/706)

## v1.2.1

What's changed since v1.2.0:

- Bug fixes:
  - Fixed export not expanding nested deployments. [#715](https://github.com/Microsoft/PSRule.Rules.Azure/issues/715)

## v1.2.0

What's changed since v1.1.4:

- New features:
  - Added `Azure.GA_2021_03` baseline. [#673](https://github.com/Microsoft/PSRule.Rules.Azure/issues/673)
    - Includes rules released before or during March 2021 for Azure GA features.
    - Marked baseline `Azure.GA_2020_12` as obsolete.
- New rules:
  - Key Vault:
    - Check vaults, keys, and secrets meet name requirements. [#646](https://github.com/microsoft/PSRule.Rules.Azure/issues/646)
- Updated rules:
  - Azure Kubernetes Service:
    - Updated `Azure.AKS.Version` to 1.19.7. [#696](https://github.com/Microsoft/PSRule.Rules.Azure/issues/696)
- General improvements:
  - Added support for user defined functions in templates. [#682](https://github.com/microsoft/PSRule.Rules.Azure/issues/682)
- Engineering:
  - Bump PSRule dependency to v1.1.0. [#692](https://github.com/microsoft/PSRule.Rules.Azure/issues/692)

What's changed since pre-release v1.2.0-B2103044:

- No additional changes.

## v1.2.0-B2103044 (pre-release)

What's changed since pre-release v1.2.0-B2103032:

- New features:
  - Added `Azure.GA_2021_03` baseline. [#673](https://github.com/Microsoft/PSRule.Rules.Azure/issues/673)
    - Includes rules released before or during March 2021 for Azure GA features.
    - Marked baseline `Azure.GA_2020_12` as obsolete.
- Updated rules:
  - Azure Kubernetes Service:
    - Updated `Azure.AKS.Version` to 1.19.7. [#696](https://github.com/Microsoft/PSRule.Rules.Azure/issues/696)

## v1.2.0-B2103032 (pre-release)

What's changed since pre-release v1.2.0-B2103024:

- New rules:
  - Key Vault:
    - Check vaults, keys, and secrets meet name requirements. [#646](https://github.com/microsoft/PSRule.Rules.Azure/issues/646)
- Engineering:
  - Bump PSRule dependency to v1.1.0. [#692](https://github.com/microsoft/PSRule.Rules.Azure/issues/692)

## v1.2.0-B2103024 (pre-release)

What's changed since v1.1.4:

- General improvements:
  - Added support for user defined functions in templates. [#682](https://github.com/microsoft/PSRule.Rules.Azure/issues/682)

## v1.1.4

What's changed since v1.1.3:

- Bug fixes:
  - Fixed handling of literal index with copyIndex function. [#686](https://github.com/microsoft/PSRule.Rules.Azure/issues/686)
  - Fixed handling of inner scoped nested deployments. [#687](https://github.com/microsoft/PSRule.Rules.Azure/issues/687)

## v1.1.3

What's changed since v1.1.2:

- Bug fixes:
  - Fixed parsing of property names for functions across multiple lines. [#683](https://github.com/microsoft/PSRule.Rules.Azure/issues/683)

## v1.1.2

What's changed since v1.1.1:

- Bug fixes:
  - Fixed copy peer property resolve. [#677](https://github.com/microsoft/PSRule.Rules.Azure/issues/677)
  - Fixed partial resource group or subscription object not populating. [#678](https://github.com/microsoft/PSRule.Rules.Azure/issues/678)
  - Fixed lazy loading of environment and resource providers. [#679](https://github.com/microsoft/PSRule.Rules.Azure/issues/679)

## v1.1.1

What's changed since v1.1.0:

- Bug fixes:
  - Fixed support for parameter file schemas. [#674](https://github.com/microsoft/PSRule.Rules.Azure/issues/674)

## v1.1.0

What's changed since v1.0.0:

- New features:
  - Exporting template with `Export-AzRuleTemplateData` supports custom resource group and subscription. [#651](https://github.com/microsoft/PSRule.Rules.Azure/issues/651)
    - Subscription and resource group used for deployment can be specified instead of using defaults.
    - `ResourceGroupName` parameter of `Export-AzRuleTemplateData` has been renamed to `ResourceGroup`.
    - Added a parameter alias for `ResourceGroupName` on `Export-AzRuleTemplateData`.
- New rules:
  - All resources:
    - Check template parameters are defined. [#631](https://github.com/microsoft/PSRule.Rules.Azure/issues/631)
    - Check location parameter is type string. [#632](https://github.com/microsoft/PSRule.Rules.Azure/issues/632)
    - Check template parameter `minValue` and `maxValue` constraints are valid. [#637](https://github.com/microsoft/PSRule.Rules.Azure/issues/637)
    - Check template resources do not use hard coded locations. [#633](https://github.com/microsoft/PSRule.Rules.Azure/issues/633)
    - Check resource group location not referenced instead of location parameter. [#634](https://github.com/microsoft/PSRule.Rules.Azure/issues/634)
    - Check increased debug detail is disabled for nested deployments. [#638](https://github.com/microsoft/PSRule.Rules.Azure/issues/638)
- General improvements:
  - Added support for matching template by name. [#661](https://github.com/microsoft/PSRule.Rules.Azure/issues/661)
    - `Get-AzRuleTemplateLink` discovers `<templateName>.json` from `<templateName>.parameters.json`.
- Engineering:
  - Bump PSRule dependency to v1.0.3. [#648](https://github.com/Microsoft/PSRule.Rules.Azure/issues/648)
- Bug fixes:
  - Fixed `Azure.VM.ADE` to limit rule to exports only. [#644](https://github.com/microsoft/PSRule.Rules.Azure/issues/644)
  - Fixed `if` condition values evaluation order. [#652](https://github.com/microsoft/PSRule.Rules.Azure/issues/652)
  - Fixed handling of `int` parameters with large values. [#653](https://github.com/microsoft/PSRule.Rules.Azure/issues/653)
  - Fixed handling of expressions split over multiple lines. [#654](https://github.com/microsoft/PSRule.Rules.Azure/issues/654)
  - Fixed handling of bool parameter values within logical expressions. [#655](https://github.com/microsoft/PSRule.Rules.Azure/issues/655)
  - Fixed copy loop value does not fall within the expected range. [#664](https://github.com/microsoft/PSRule.Rules.Azure/issues/664)
  - Fixed template comparison functions handling of large integer values. [#666](https://github.com/microsoft/PSRule.Rules.Azure/issues/666)
  - Fixed handling of `createArray` function with no arguments. [#667](https://github.com/microsoft/PSRule.Rules.Azure/issues/667)

What's changed since pre-release v1.1.0-B2102034:

- No additional changes.

## v1.1.0-B2102034 (pre-release)

What's changed since pre-release v1.1.0-B2102023:

- General improvements:
  - Added support for matching template by name. [#661](https://github.com/microsoft/PSRule.Rules.Azure/issues/661)
    - `Get-AzRuleTemplateLink` discovers `<templateName>.json` from `<templateName>.parameters.json`.
- Bug fixes:
  - Fixed copy loop value does not fall within the expected range. [#664](https://github.com/microsoft/PSRule.Rules.Azure/issues/664)
  - Fixed template comparison functions handling of large integer values. [#666](https://github.com/microsoft/PSRule.Rules.Azure/issues/666)
  - Fixed handling of `createArray` function with no arguments. [#667](https://github.com/microsoft/PSRule.Rules.Azure/issues/667)

## v1.1.0-B2102023 (pre-release)

What's changed since pre-release v1.1.0-B2102015:

- New features:
  - Exporting template with `Export-AzRuleTemplateData` supports custom resource group and subscription. [#651](https://github.com/microsoft/PSRule.Rules.Azure/issues/651)
    - Subscription and resource group used for deployment can be specified instead of using defaults.
    - `ResourceGroupName` parameter of `Export-AzRuleTemplateData` has been renamed to `ResourceGroup`.
    - Added a parameter alias for `ResourceGroupName` on `Export-AzRuleTemplateData`.

## v1.1.0-B2102015 (pre-release)

What's changed since pre-release v1.1.0-B2102010:

- Bug fixes:
  - Fixed `if` condition values evaluation order. [#652](https://github.com/microsoft/PSRule.Rules.Azure/issues/652)
  - Fixed handling of `int` parameters with large values. [#653](https://github.com/microsoft/PSRule.Rules.Azure/issues/653)
  - Fixed handling of expressions split over multiple lines. [#654](https://github.com/microsoft/PSRule.Rules.Azure/issues/654)
  - Fixed handling of bool parameter values within logical expressions. [#655](https://github.com/microsoft/PSRule.Rules.Azure/issues/655)

## v1.1.0-B2102010 (pre-release)

What's changed since pre-release v1.1.0-B2102001:

- Engineering:
  - Bump PSRule dependency to v1.0.3. [#648](https://github.com/Microsoft/PSRule.Rules.Azure/issues/648)
- Bug fixes:
  - Fixed `Azure.VM.ADE` to limit rule to exports only. [#644](https://github.com/microsoft/PSRule.Rules.Azure/issues/644)

## v1.1.0-B2102001 (pre-release)

What's changed since v1.0.0:

- New rules:
  - All resources:
    - Check template parameters are defined. [#631](https://github.com/microsoft/PSRule.Rules.Azure/issues/631)
    - Check location parameter is type string. [#632](https://github.com/microsoft/PSRule.Rules.Azure/issues/632)
    - Check template parameter `minValue` and `maxValue` constraints are valid. [#637](https://github.com/microsoft/PSRule.Rules.Azure/issues/637)
    - Check template resources do not use hard coded locations. [#633](https://github.com/microsoft/PSRule.Rules.Azure/issues/633)
    - Check resource group location not referenced instead of location parameter. [#634](https://github.com/microsoft/PSRule.Rules.Azure/issues/634)
    - Check increased debug detail is disabled for nested deployments. [#638](https://github.com/microsoft/PSRule.Rules.Azure/issues/638)
- Engineering:
  - Bump PSRule dependency to v1.0.2. [#635](https://github.com/Microsoft/PSRule.Rules.Azure/issues/635)

## v1.0.0

What's changed since v0.19.0:

- New rules:
  - All resources:
    - Check parameter default value type matches type. [#311](https://github.com/Microsoft/PSRule.Rules.Azure/issues/311)
    - Check location parameter defaults to resource group. [#361](https://github.com/Microsoft/PSRule.Rules.Azure/issues/361)
  - Front Door:
    - Check Front Door uses a health probe for each backend pool. [#546](https://github.com/Microsoft/PSRule.Rules.Azure/issues/546)
    - Check Front Door uses a dedicated health probe path backend pools. [#547](https://github.com/Microsoft/PSRule.Rules.Azure/issues/547)
    - Check Front Door uses HEAD requests for backend health probes. [#613](https://github.com/Microsoft/PSRule.Rules.Azure/issues/613)
  - Service Fabric:
    - Check Service Fabric clusters use AAD client authentication. [#619](https://github.com/Microsoft/PSRule.Rules.Azure/issues/619)
- Updated rules:
  - Azure Kubernetes Service:
    - Updated `Azure.AKS.Version` to 1.19.6. [#603](https://github.com/Microsoft/PSRule.Rules.Azure/issues/603)
- General improvements:
  - Renamed `Export-AzTemplateRuleData` to `Export-AzRuleTemplateData`. [#596](https://github.com/Microsoft/PSRule.Rules.Azure/issues/596)
    - New name `Export-AzRuleTemplateData` aligns with prefix of other cmdlets.
    - Use of `Export-AzTemplateRuleData` is now deprecated and will be removed in the next major version.
    - Added alias to allow `Export-AzTemplateRuleData` to continue to be used.
    - Using `Export-AzTemplateRuleData` returns a deprecation warning.
  - Added support for `environment` template function. [#517](https://github.com/Microsoft/PSRule.Rules.Azure/issues/517)
- Engineering:
  - Bump PSRule dependency to v1.0.1. [#611](https://github.com/Microsoft/PSRule.Rules.Azure/issues/611)

What's changed since pre-release v1.0.0-B2101028:

- No additional changes.

## v1.0.0-B2101028 (pre-release)

What's changed since pre-release v1.0.0-B2101016:

- New rules:
  - All resources:
    - Check parameter default value type matches type. [#311](https://github.com/Microsoft/PSRule.Rules.Azure/issues/311)
- General improvements:
  - Renamed `Export-AzTemplateRuleData` to `Export-AzRuleTemplateData`. [#596](https://github.com/Microsoft/PSRule.Rules.Azure/issues/596)
    - New name `Export-AzRuleTemplateData` aligns with prefix of other cmdlets.
    - Use of `Export-AzTemplateRuleData` is now deprecated and will be removed in the next major version.
    - Added alias to allow `Export-AzTemplateRuleData` to continue to be used.
    - Using `Export-AzTemplateRuleData` returns a deprecation warning.

## v1.0.0-B2101016 (pre-release)

What's changed since pre-release v1.0.0-B2101006:

- New rules:
  - Service Fabric:
    - Check Service Fabric clusters use AAD client authentication. [#619](https://github.com/Microsoft/PSRule.Rules.Azure/issues/619)
- Bug fixes:
  - Fixed reason `Azure.FrontDoor.ProbePath` so the probe name is included. [#617](https://github.com/Microsoft/PSRule.Rules.Azure/issues/617)

## v1.0.0-B2101006 (pre-release)

What's changed since v0.19.0:

- New rules:
  - All resources:
    - Check location parameter defaults to resource group. [#361](https://github.com/Microsoft/PSRule.Rules.Azure/issues/361)
  - Front Door:
    - Check Front Door uses a health probe for each backend pool. [#546](https://github.com/Microsoft/PSRule.Rules.Azure/issues/546)
    - Check Front Door uses a dedicated health probe path backend pools. [#547](https://github.com/Microsoft/PSRule.Rules.Azure/issues/547)
    - Check Front Door uses HEAD requests for backend health probes. [#613](https://github.com/Microsoft/PSRule.Rules.Azure/issues/613)
- Updated rules:
  - Azure Kubernetes Service:
    - Updated `Azure.AKS.Version` to 1.19.6. [#603](https://github.com/Microsoft/PSRule.Rules.Azure/issues/603)
- General improvements:
  - Added support for `environment` template function. [#517](https://github.com/Microsoft/PSRule.Rules.Azure/issues/517)
- Engineering:
  - Bump PSRule dependency to v1.0.1. [#611](https://github.com/Microsoft/PSRule.Rules.Azure/issues/611)

[troubleshooting guide]: troubleshooting.md
