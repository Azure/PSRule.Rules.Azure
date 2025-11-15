# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Cosmos DB

#region Rules

# Synopsis: Enable Microsoft Defender for Azure Cosmos DB.
Rule 'Azure.Cosmos.DefenderCloud' -Ref 'AZR-000382' -Type 'Microsoft.DocumentDb/databaseAccounts' -If { $Configuration.AZURE_COSMOS_DEFENDER_PER_ACCOUNT -and (Test-IsNoSQL) } -Tag @{ release = 'GA'; ruleSet = '2023_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-2', 'LT-1' } {
    $defender = @(GetSubResources -ResourceType 'Microsoft.Security/advancedThreatProtectionSettings' |
        Where-Object { $_.properties.isEnabled -eq $True })
    $Assert.GreaterOrEqual($defender, '.', 1).Reason($LocalizedData.SubResourceNotFound, 'Microsoft.Security/advancedThreatProtectionSettings')
} -Configure @{ AZURE_COSMOS_DEFENDER_PER_ACCOUNT = $False }

# Synopsis: Cosmos DB has local authentication disabled.
Rule 'Azure.Cosmos.DisableLocalAuth' -Ref 'AZR-000420' -Type 'Microsoft.DocumentDb/databaseAccounts' -If { Test-IsNoSQL } -Tag @{ release = 'GA'; ruleSet = '2024_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'IM-1'; 'Azure.WAF/maturity' = 'L1' } {
    $Assert.HasFieldValue($TargetObject, 'properties.DisableLocalAuth', $true)
}

# Synopsis: Use zone redundant Cosmos DB accounts in supported regions to improve reliability.
Rule 'Azure.Cosmos.AvailabilityZone' -Ref 'AZR-000502' -Type 'Microsoft.DocumentDb/databaseAccounts' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Reliability'; } -Labels @{ 'Azure.WAF/maturity' = 'L1' } {
    # Check for availability zones based on virtual machine scale sets, because it is not exposed through the provider for Cosmos DB.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets');

    $Assert.GreaterOrEqual($TargetObject, 'properties.locations', 1);

    if ($TargetObject.properties.locations) {
        foreach ($location in $TargetObject.properties.locations) {
            $availabilityZones = GetAvailabilityZone -Location $location.locationName -Zone $provider.ZoneMappings;

            # If the location supports availability zones, ensure zone redundancy is enabled
            if ($availabilityZones) {
                $Assert.HasFieldValue($location, 'isZoneRedundant', $true).
                ReasonFrom('properties.locations', $LocalizedData.CosmosDBAvailabilityZone, $TargetObject.Name, $location.locationName);
            }
        }
    }
}

# Synopsis: Use zone redundant Cosmos DB vCore clusters in supported regions to improve reliability.
Rule 'Azure.Cosmos.MongoAvailabilityZone' -Ref 'AZR-000503' -Type 'Microsoft.DocumentDB/mongoClusters' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Reliability'; } -Labels @{ 'Azure.WAF/maturity' = 'L1' } {
    # Check for availability zones based on virtual machine scale sets, because it is not exposed through the provider for Cosmos DB.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets');
    
    $location = $TargetObject.Location;
    $availabilityZones = GetAvailabilityZone -Location $location -Zone $provider.ZoneMappings;

    # If the location supports availability zones, ensure zone redundancy is enabled
    if ($availabilityZones) {
        $Assert.HasFieldValue($TargetObject, 'properties.highAvailability.targetMode', 'ZoneRedundantPreferred').
        ReasonFrom('properties.highAvailability.targetMode', $LocalizedData.MongoDBvCoreAvailabilityZone, $TargetObject.Name, $location);
    }
    else {
        # Pass if the region does not support availability zones
        $Assert.Pass();
    }
}

# Synopsis: Azure Cosmos DB for Apache Cassandra accounts without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.Cosmos.CassandraNaming' -Ref 'AZR-000513' -Type 'Microsoft.DocumentDb/databaseAccounts' -With 'Azure.Cosmos.IsCassandra' -If { $Configuration['AZURE_COSMOS_CASSANDRA_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming'; 'Azure.WAF/maturity' = 'L2' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_COSMOS_CASSANDRA_NAME_FORMAT, $True);
}

# Synopsis: Azure Cosmos DB for MongoDB accounts without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.Cosmos.MongoNaming' -Ref 'AZR-000514' -Type 'Microsoft.DocumentDb/databaseAccounts' -If { $Configuration['AZURE_COSMOS_MONGO_NAME_FORMAT'] -ne '' -and $TargetObject.kind -eq 'MongoDB' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming'; 'Azure.WAF/maturity' = 'L2' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_COSMOS_MONGO_NAME_FORMAT, $True);
}

# Synopsis: Azure Cosmos DB for NoSQL accounts without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.Cosmos.NoSQLNaming' -Ref 'AZR-000515' -Type 'Microsoft.DocumentDb/databaseAccounts' -If { $Configuration['AZURE_COSMOS_NOSQL_NAME_FORMAT'] -ne '' -and (Test-IsNoSQL) } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming'; 'Azure.WAF/maturity' = 'L2' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_COSMOS_NOSQL_NAME_FORMAT, $True);
}

# Synopsis: Azure Cosmos DB for Table accounts without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.Cosmos.TableNaming' -Ref 'AZR-000516' -Type 'Microsoft.DocumentDb/databaseAccounts' -With 'Azure.Cosmos.IsTable' -If { $Configuration['AZURE_COSMOS_TABLE_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming'; 'Azure.WAF/maturity' = 'L2' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_COSMOS_TABLE_NAME_FORMAT, $True);
}

# Synopsis: Azure Cosmos DB for Apache Gremlin accounts without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.Cosmos.GremlinNaming' -Ref 'AZR-000517' -Type 'Microsoft.DocumentDb/databaseAccounts' -With 'Azure.Cosmos.IsGremlin' -If { $Configuration['AZURE_COSMOS_GREMLIN_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming'; 'Azure.WAF/maturity' = 'L2' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_COSMOS_GREMLIN_NAME_FORMAT, $True);
}

# Synopsis: Azure Cosmos DB PostgreSQL clusters without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.Cosmos.PostgreSQLNaming' -Ref 'AZR-000518' -Type 'Microsoft.DBforPostgreSQL/serverGroupsv2' -If { $Configuration['AZURE_COSMOS_POSTGRESQL_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming'; 'Azure.WAF/maturity' = 'L2' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_COSMOS_POSTGRESQL_NAME_FORMAT, $True);
}

# Synopsis: Azure Cosmos DB databases without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.Cosmos.DatabaseNaming' -Ref 'AZR-000519' -Type 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases' -If { $Configuration['AZURE_COSMOS_DATABASE_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming'; 'Azure.WAF/maturity' = 'L2' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_COSMOS_DATABASE_NAME_FORMAT, $True);
}

#endregion Rules

#region Helper functions

function global:Test-IsNoSQL {
    [CmdletBinding()]
    param ( )

    if ($TargetObject.kind -ne 'GlobalDocumentDB') {
        return $false
    }
    if (-not $TargetObject.properties.capabilities) {
        return $true
    }
    $TargetObject.properties.capabilities.Where({ $_.name -in @('EnableTable', 'EnableCassandra', 'EnableGremlin') }, 'First').Count -eq 0
}

#endregion Helper functions
