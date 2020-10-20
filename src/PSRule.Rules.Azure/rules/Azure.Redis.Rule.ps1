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

#endregion Helper functions
