# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for public IP addresses
#

# Synopsis: Public IP addresses should be attached or cleaned up if not in use
Rule 'Azure.PublicIP.IsAttached' -Type 'Microsoft.Network/publicIPAddresses' -If { IsExport } -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.ipConfiguration.id')
}

# Synopsis: Use public IP address naming requirements
Rule 'Azure.PublicIP.Name' -Type 'Microsoft.Network/publicIPAddresses' -Tag @{ release = 'GA' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork

    # Between 1 and 80 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 1)
    $Assert.LessOrEqual($TargetObject, 'Name', 80)

    # Alphanumerics, underscores, periods, and hyphens.
    # Start with alphanumeric. End alphanumeric or underscore.
    Match 'Name' '^[A-Za-z0-9]((-|\.)*\w){0,79}$'
}

# Synopsis: Use public IP DNS label naming requirements
Rule 'Azure.PublicIP.DNSLabel' -Type 'Microsoft.Network/publicIPAddresses' -If { $Assert.HasFieldValue($TargetObject, 'Properties.dnsSettings.domainNameLabel') } -Tag @{ release = 'GA' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork

    # Between 3 and 63 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Properties.dnsSettings.domainNameLabel', 3)
    $Assert.LessOrEqual($TargetObject, 'Properties.dnsSettings.domainNameLabel', 63)

    # Lowercase letters, numbers, and hyphens.
    # Start with a letter.
    # End with a letter or number.
    Match 'Properties.dnsSettings.domainNameLabel' '^[a-z][a-z0-9-]{1,61}[a-z0-9]$' -CaseSensitive
}
