# Change log

**Important notes**:

- Issue #741: `Could not load file or assembly YamlDotNet`.
See [troubleshooting guide] for a workaround to this issue.

## Unreleased

## v1.5.0-B2107002 (pre-release)

What's changed since pre-release v1.5.0-B2106018:

- New features:
  - Added `Azure.GA_2021_06` baseline. [#822](https://github.com/Azure/PSRule.Rules.Azure/issues/822)
    - Includes rules released before or during June 2021 for Azure GA features.
    - Marked baseline `Azure.GA_2021_03` as obsolete.
- General improvements:
  - Updated rule help to use docs pages for online version. [#824](https://github.com/Azure/PSRule.Rules.Azure/issues/824)
- Engineering:
  - Bump PSDocs dependency to v1.4.0. [#823](https://github.com/Azure/PSRule.Rules.Azure/issues/823)
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
- Updated rules
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
- Updated rules
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
