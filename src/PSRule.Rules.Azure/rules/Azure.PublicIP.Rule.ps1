# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for public IP addresses
#

# Synopsis: Public IP addresses should be attached or cleaned up if not in use.
Rule 'Azure.PublicIP.IsAttached' -Ref 'AZR-000154' -Type 'Microsoft.Network/publicIPAddresses' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'NS-1' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.ipConfiguration.id');
}

# Synopsis: Use public IP address naming requirements
Rule 'Azure.PublicIP.Name' -Ref 'AZR-000155' -Type 'Microsoft.Network/publicIPAddresses' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork

    # Between 1 and 80 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 1);
    $Assert.LessOrEqual($PSRule, 'TargetName', 80);

    # Alphanumerics, underscores, periods, and hyphens.
    # Start with alphanumeric. End alphanumeric or underscore.
    $Assert.Match($PSRule, 'TargetName', '^[A-Za-z0-9]((-|\.)*\w){0,79}$');
}

# Synopsis: Use public IP DNS label naming requirements
Rule 'Azure.PublicIP.DNSLabel' -Ref 'AZR-000156' -Type 'Microsoft.Network/publicIPAddresses' -If { $Assert.HasFieldValue($TargetObject, 'Properties.dnsSettings.domainNameLabel') } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftnetwork

    # Between 3 and 63 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Properties.dnsSettings.domainNameLabel', 3);
    $Assert.LessOrEqual($TargetObject, 'Properties.dnsSettings.domainNameLabel', 63);

    # Lowercase letters, numbers, and hyphens.
    # Start with a letter.
    # End with a letter or number.
    $Assert.Match($TargetObject, 'Properties.dnsSettings.domainNameLabel', '^[a-z][a-z0-9-]{1,61}[a-z0-9]$', $True);
}

# Synopsis: Public IP addresses deployed with Standard SKU should use availability zones in supported regions for high availability.
Rule 'Azure.PublicIP.AvailabilityZone' -Ref 'AZR-000157' -With 'Azure.PublicIP.ShouldBeAvailable' -Tag @{ release = 'GA'; ruleSet = '2021_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $publicIpAddressProvider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Network', 'publicIPAddresses');

    $configurationZoneMappings = $Configuration.AZURE_PUBLICIP_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST;
    $providerZoneMappings = $publicIpAddressProvider.ZoneMappings;
    $mergedAvailabilityZones = PrependConfigurationZoneWithProviderZone -ConfigurationZone $configurationZoneMappings -ProviderZone $providerZoneMappings;

    $availabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $mergedAvailabilityZones;

    if (-not $availabilityZones) {
        return $Assert.Pass();
    }

    $Assert.AllOf(
        $Assert.HasFieldValue($TargetObject, 'zones'),
        $Assert.SetOf($TargetObject, 'zones', @('1', '2', '3'))
    ).Reason(
        $LocalizedData.PublicIPAvailabilityZone, 
        $TargetObject.name, 
        $TargetObject.Location
    )

} -Configure @{ AZURE_PUBLICIP_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST = @() }

# Synopsis: Use standard public IP address names.
Rule 'Azure.PublicIP.Naming' -Ref 'AZR-000471' -Type 'Microsoft.Network/publicIPAddresses' -If { $Configuration['AZURE_PUBLIC_IP_ADDRESS_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_06'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_PUBLIC_IP_ADDRESS_NAME_FORMAT, $True);
}

#region Helper functions

function global:IsStandardPublicIP {
    [CmdletBinding()]
    [OutputType([PSRule.Runtime.AssertResult])]
    param ()
    process {
        return $Assert.HasFieldValue($TargetObject, 'sku.name', 'Standard');
    }
}

#endregion Helper functions
