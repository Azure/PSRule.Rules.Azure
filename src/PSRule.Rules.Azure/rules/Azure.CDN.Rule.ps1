# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure CDN
#

# Synopsis: Only use secure transport
Rule 'Azure.CDN.HTTP' -Type 'Microsoft.Cdn/profiles/endpoints' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'properties.isHttpAllowed', $False)
}

# Synopsis: Use CDN endpoint naming requirements
Rule 'Azure.CDN.EndpointName' -Type 'Microsoft.Cdn/profiles/endpoints' -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcdn

    $nameParts = $PSRule.TargetName.Split('/');
    $name = $nameParts[-1];

    # Between 1 and 50 characters long
    $Assert.GreaterOrEqual($name, '.', 1)
    $Assert.LessOrEqual($name, '.', 50)

    # Alphanumerics and hyphens.
    # Start and end with alphanumeric.
    $Assert.Match($name, '.', '^[a-zA-Z0-9](([a-zA-Z0-9]|-)*[a-zA-Z0-9]){0,49}$')
}

# Synopsis: Consider configuring the minimum supported TLS version to be 1.2.
Rule 'Azure.CDN.MinTLS' -Type 'Microsoft.Cdn/profiles/endpoints', 'Microsoft.Cdn/profiles/endpoints/customdomains' -Tag @{ release = 'GA'; ruleSet = '2020_09' } {
    $customDomains = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.Cdn/profiles/endpoints') {
        $customDomains = @(GetSubResources -ResourceType 'Microsoft.Cdn/profiles/endpoints/customdomains');
    }
    if ($customDomains.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($customDomain in $customDomains) {
        $Assert.HasFieldValue($customDomain, 'properties.customHttpsParameters.minimumTlsVersion', 'TLS12')
    }
}
