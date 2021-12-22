# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Redis Cache
#

# Synopsis: Redis Cache should only accept secure connections
Rule 'Azure.Redis.NonSslPort' -Type 'Microsoft.Cache/Redis' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'properties.enableNonSslPort', $False);
}

# Synopsis: Redis Cache should reject TLS versions older then 1.2
Rule 'Azure.Redis.MinTLS' -Type 'Microsoft.Cache/Redis' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.Version($TargetObject, 'properties.minimumTlsVersion', '>=1.2');
}

# Synopsis: Use Azure Cache for Redis instances of at least Standard C1.
Rule 'Azure.Redis.MinSKU' -Type 'Microsoft.Cache/Redis' -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $Assert.In($TargetObject, 'Properties.sku.name', @('Standard', 'Premium'));
    if ($TargetObject.Properties.sku.name -eq 'Standard') {
        $Assert.GreaterOrEqual($TargetObject, 'Properties.sku.capacity', 1);
    }
}

# Synopsis: Configure `maxmemory-reserved` to reserve memory for non-cache operations.
Rule 'Azure.Redis.MaxMemoryReserved' -Type 'Microsoft.Cache/Redis' -Tag @{ release = 'GA'; ruleSet = '2020_12'; } {
    $sku = "$($TargetObject.Properties.sku.family)$($TargetObject.Properties.sku.capacity)";
    $memSize = (GetCacheMemory -Sku $sku) / 1MB;
    $Assert.GreaterOrEqual($TargetObject, 'Properties.redisConfiguration.maxmemory-reserved', $memSize * 0.1, $True);
}

# Synopsis: Premium and Enterprise Redis cache should be deployed with availability zones for high availability.
Rule 'Azure.Redis.AvailabilityZone' -Type 'Microsoft.Cache/Redis' -If { (IsPremiumCache) -or (IsEnterpriseCache) } -Tag @{ release = 'GA'; ruleSet = '2021_12'; } {
    $redisCacheProvider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Cache', 'Redis');

    $configurationZoneMappings = $Configuration.AZURE_REDISCACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST;
    $providerZoneMappings = $redisCacheProvider.ZoneMappings;
    $mergedAvailabilityZones = PrependConfigurationZoneWithProviderZone -ConfigurationZone $configurationZoneMappings -ProviderZone $providerZoneMappings;

    $locationAvailabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $mergedAvailabilityZones;

    if (-not $locationAvailabilityZones) {
        return $Assert.Pass();
    }

    $capacityUnitMapping = @{
        'Premium' = @(1, 2, 3, 4, 5)
        'Enterprise' = @(2, 4, 6, 8, 10)
        'EnterpriseFlash' = @(3, 9)
    }

    $skuName = $TargetObject.Properties.sku.name;

    # If Premium Cache
    # Need to check zones are greater or equal to 2 and replicas are n(number of zones) - 1
    if (IsPremiumCache) {
        $Assert.AllOf(
            $Assert.GreaterOrEqual($TargetObject, 'Properties.replicasPerMaster', $TargetObject.zones.Length - 1),
            $Assert.GreaterOrEqual($TargetObject, 'zones', 2),
            $Assert.In($TargetObject, 'Properties.sku.capacity', $capacityUnitMapping[$skuName])
        ).Reason(
            $LocalizedData.PremiumRedisCacheAvailabilityZone, 
            $TargetObject.name, 
            $TargetObject.location, 
            ($locationAvailabilityZones -join ', ')
        );
    }

    # Enterprise Cache
    # Check if zone redundant(1, 2 and 3)
    else {
        $zoneRedundant = $TargetObject.zones -and (-not (Compare-Object -ReferenceObject @('1', '2', '3') -DifferenceObject $TargetObject.zones));

        $skuPrefix = $skuName.Split('_')[0];

        $hasValidCapacityUnits = $Assert.In($TargetObject, 'Properties.sku.capacity', $capacityUnitMapping[$skuPrefix]).Result;

        $Assert.Create(
            ($zoneRedundant -and $hasValidCapacityUnits),
            $LocalizedData.EnterpriseRedisCacheAvailabilityZone,
            $TargetObject.name,
            $TargetObject.location
        );
    }

} -Configure @{ AZURE_REDISCACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST = @() }

#region Helper functions

function global:GetCacheMemory {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Sku
    )
    process {
        switch ($Sku) {
            "C0" { return 250MB; }
            "C1" { return 1GB; }
            "C2" { return 2.5GB; }
            "C3" { return 6GB; }
            "C4" { return 13GB; }
            "C5" { return 26GB; }
            "C6" { return 53GB; }
            "P1" { return 6GB; }
            "P2" { return 13GB; }
            "P3" { return 26GB; }
            "P4" { return 53GB; }
            "P5" { return 120GB; }
        }
    }
}

function global:IsPremiumCache {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        return $Assert.AllOf(
            $Assert.HasFieldValue($TargetObject, 'Properties.sku.name', 'Premium'),
            $Assert.HasFieldValue($TargetObject, 'Properties.sku.family', 'P')
        ).Result
    }
}

function global:IsEnterpriseCache {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        return $Assert.In($TargetObject, 'Properties.sku.name', @(
            'Enterprise_E10', 
            'Enterprise_E20', 
            'Enterprise_E50',
            'Enterprise_E100',
            'EnterpriseFlash_F300',
            'EnterpriseFlash_F700',
            'EnterpriseFlash_F1500')).Result;
    }
}

#endregion Helper functions
