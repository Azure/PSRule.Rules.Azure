# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure CDN
#

# Synopsis: Only use secure transport
Rule 'Azure.CDN.HTTP' -Type 'Microsoft.Cdn/profiles/endpoints' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'properties.isHttpAllowed', $False)
}
