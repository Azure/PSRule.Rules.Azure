# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure DocumentDB

#region Rules

# Synopsis: Use zone redundant Azure DocumentDB clusters in supported regions to improve reliability.
Rule 'Azure.DocumentDB.AvailabilityZone' -Ref 'AZR-000503' -Alias 'Azure.Cosmos.MongoAvailabilityZone' -Type 'Microsoft.DocumentDB/mongoClusters' -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Reliability'; } -Labels @{ 'Azure.WAF/maturity' = 'L1' } {
    # Use VM scale set zone mappings because the DocumentDB provider does not expose availability zones.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets');

    $location = $TargetObject.Location;
    $availabilityZones = GetAvailabilityZone -Location $location -Zone $provider.ZoneMappings;

    if ($availabilityZones) {
        $Assert.HasFieldValue($TargetObject, 'properties.highAvailability.targetMode', 'ZoneRedundantPreferred').
        ReasonFrom('properties.highAvailability.targetMode', $LocalizedData.DocumentDBAvailabilityZone, $TargetObject.Name, $location);
    }
    else {
        $Assert.Pass();
    }
}

# Synopsis: Deployed Azure DocumentDB clusters should disable native authentication.
Rule 'Azure.DocumentDB.LocalAuth' -Ref 'AZR-000547' -Type 'Microsoft.DocumentDB/mongoClusters' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2027_03'; 'Azure.WAF/pillar' = 'Security'; method = 'in-flight'; } -Labels @{ 'Azure.MCSB.v1/control' = 'IM-1'; 'Azure.WAF/maturity' = 'L1' } {
    $Assert.SetOf($TargetObject, 'properties.authConfig.allowedModes', @('MicrosoftEntraID'));
}

# Synopsis: Azure DocumentDB cluster names should meet resource naming requirements.
Rule 'Azure.DocumentDB.Name' -Ref 'AZR-000548' -Type 'Microsoft.DocumentDB/mongoClusters' -Tag @{ release = 'GA'; ruleSet = '2027_03'; 'Azure.WAF/pillar' = 'Operational Excellence'; } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 3);
    $Assert.LessOrEqual($PSRule, 'TargetName', 40);
    $Assert.Match($PSRule, 'TargetName', '^[a-z0-9]+(-[a-z0-9]+)*$', $True);
}

# Synopsis: Azure DocumentDB clusters without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.DocumentDB.Naming' -Ref 'AZR-000549' -Type 'Microsoft.DocumentDB/mongoClusters' -If { ![String]::IsNullOrEmpty($Configuration.AZURE_DOCUMENTDB_CLUSTER_NAME_FORMAT) } -Tag @{ release = 'GA'; ruleSet = '2027_03'; 'Azure.WAF/pillar' = 'Operational Excellence'; } -Labels @{ 'Azure.CAF' = 'naming'; 'Azure.WAF/maturity' = 'L2' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_DOCUMENTDB_CLUSTER_NAME_FORMAT, $True);
}

# Synopsis: Azure DocumentDB clusters should limit the number of firewall rules.
Rule 'Azure.DocumentDB.FirewallRuleCount' -Ref 'AZR-000550' -Type 'Microsoft.DocumentDB/mongoClusters' -Tag @{ release = 'GA'; ruleSet = '2027_03'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'NS-2'; 'Azure.WAF/maturity' = 'L1' } {
    $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DocumentDB/mongoClusters/firewallRules', 'firewallRules');
    $Assert.LessOrEqual($firewallRules, '.', 10).
    Reason($LocalizedData.ExceededFirewallRuleCount, $firewallRules.Length, 10);
}

# Synopsis: Azure DocumentDB firewall rules should limit the number of permitted IP addresses.
Rule 'Azure.DocumentDB.FirewallIPRange' -Ref 'AZR-000551' -Type 'Microsoft.DocumentDB/mongoClusters', 'Microsoft.DocumentDB/mongoClusters/firewallRules' -Tag @{ release = 'GA'; ruleSet = '2027_03'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'NS-2'; 'Azure.WAF/maturity' = 'L1' } {
    $firewallRules = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.DocumentDB/mongoClusters') {
        $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DocumentDB/mongoClusters/firewallRules', 'firewallRules');
    }

    [UInt64]$count = 0;
    foreach ($firewallRule in $firewallRules) {
        $hasStart = $Assert.HasFieldValue($firewallRule, 'properties.startIpAddress');
        $hasEnd = $Assert.HasFieldValue($firewallRule, 'properties.endIpAddress');
        $hasStart;
        $hasEnd;
        if ($hasStart.Result -and $hasEnd.Result) {
            # The Azure-wide access sentinel is checked separately by AllowAzureAccess.
            if ($firewallRule.properties.startIpAddress -eq '0.0.0.0' -and $firewallRule.properties.endIpAddress -eq '0.0.0.0') {
                continue;
            }
            $count += GetIPAddressCount -Start $firewallRule.properties.startIpAddress -End $firewallRule.properties.endIpAddress;
        }
    }
    $Assert.LessOrEqual($count, '.', 10).Reason($LocalizedData.DocumentDBFirewallIPRange, $count, 10);
}

# Synopsis: Azure DocumentDB clusters should not allow access from all Azure services.
Rule 'Azure.DocumentDB.AllowAzureAccess' -Ref 'AZR-000552' -Type 'Microsoft.DocumentDB/mongoClusters', 'Microsoft.DocumentDB/mongoClusters/firewallRules' -Tag @{ release = 'GA'; ruleSet = '2027_03'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'NS-2'; 'Azure.WAF/maturity' = 'L1' } {
    $firewallRules = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.DocumentDB/mongoClusters') {
        $firewallRules = @(GetSubResources -ResourceType 'Microsoft.DocumentDB/mongoClusters/firewallRules', 'firewallRules');
    }
    $azureAccess = @($firewallRules | Where-Object {
        $_.properties.startIpAddress -eq '0.0.0.0' -and $_.properties.endIpAddress -eq '0.0.0.0'
    });
    $Assert.LessOrEqual($azureAccess, '.', 0).Reason($LocalizedData.DocumentDBAzureAccess);
}

# Synopsis: Azure DocumentDB clusters on supported compute tiers should enable request diagnostic logs.
Rule 'Azure.DocumentDB.DiagnosticLogs' -Ref 'AZR-000553' -Type 'Microsoft.DocumentDB/mongoClusters' -If { $TargetObject.properties.compute.tier -match '^M(\d+)$' -and [int]$Matches[1] -gt 30 } -Tag @{ release = 'GA'; ruleSet = '2027_03'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'LT-4'; 'Azure.WAF/maturity' = 'L1' } {
    $logs = @(GetSubResources -ResourceType 'Microsoft.Insights/diagnosticSettings', 'Microsoft.DocumentDB/mongoClusters/providers/diagnosticSettings' |
        ForEach-Object { $_.properties.logs | Where-Object {
            ($_.category -eq 'vCoreMongoRequests' -or $_.categoryGroup -eq 'allLogs') -and $_.enabled -eq $True
        } });
    $Assert.Greater($logs, '.', 0).Reason($LocalizedData.DiagnosticSettingsLoggingNotConfigured, 'vCoreMongoRequests').
    PathPrefix('resources');
}

# Synopsis: Azure DocumentDB clusters should use customer-managed encryption keys when required.
Rule 'Azure.DocumentDB.CMK' -Ref 'AZR-000554' -Type 'Microsoft.DocumentDB/mongoClusters' -If { $Configuration.AZURE_DOCUMENTDB_REQUIRE_CMK -eq $True } -Tag @{ release = 'GA'; ruleSet = '2027_03'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-5'; 'Azure.WAF/maturity' = 'L2' } {
    $Assert.HasFieldValue($TargetObject, 'properties.encryption.customerManagedKeyEncryption.keyEncryptionKeyUrl');
    $Assert.HasFieldValue($TargetObject, 'properties.encryption.customerManagedKeyEncryption.keyEncryptionKeyIdentity.identityType', 'UserAssignedIdentity');
    $identityId = $TargetObject.properties.encryption.customerManagedKeyEncryption.keyEncryptionKeyIdentity.userAssignedIdentityResourceId;
    $Assert.HasFieldValue($TargetObject, 'properties.encryption.customerManagedKeyEncryption.keyEncryptionKeyIdentity.userAssignedIdentityResourceId');
    $Assert.In($TargetObject, 'identity.type', @('UserAssigned', 'SystemAssigned,UserAssigned', 'SystemAssigned, UserAssigned'));
    if ($identityId) {
        $assignedIdentities = @($TargetObject.identity.userAssignedIdentities.PSObject.Properties.Name);
        $Assert.In($TargetObject, 'properties.encryption.customerManagedKeyEncryption.keyEncryptionKeyIdentity.userAssignedIdentityResourceId', $assignedIdentities);
    }
}

#endregion Rules
