# Change log

## Unreleased

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
