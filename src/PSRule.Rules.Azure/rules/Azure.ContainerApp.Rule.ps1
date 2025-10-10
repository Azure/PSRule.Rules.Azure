# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Container Apps
#

#region Rules

# Synopsis: IP ingress restrictions mode should be set to allow action for all rules defined.
Rule 'Azure.ContainerApp.RestrictIngress' -Ref 'AZR-000380' -Type 'Microsoft.App/containerApps' -If { HasIngress } -Tag @{ release = 'GA'; ruleSet = '2023_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'NS-2' } {
    $restrictions = @($TargetObject.properties.configuration.ingress.ipSecurityRestrictions)
    if (!$restrictions) {
        return $Assert.Fail()
    }
    foreach ($restriction in $restrictions) {
        $Assert.HasFieldValue($restriction, 'action', 'Allow')
    }
}

# Synopsis: Use Container Apps environments that are zone redundant to improve reliability.
Rule 'Azure.ContainerApp.AvailabilityZone' -Ref 'AZR-000414' -Type 'Microsoft.App/managedEnvironments' -Tag @{ release = 'GA'; ruleSet = '2024_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    # Check for availability zones based on Compute, because it is not exposed through the provider for container apps.
    $provider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets');
    $availabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $provider.ZoneMappings;

    # Don't flag if the region does not support AZ.
    if (-not $availabilityZones) {
        return $Assert.Pass();
    }

    $Assert.HasFieldValue($TargetObject, 'properties.zoneRedundant', $True);
    $Assert.HasFieldValue($TargetObject, 'properties.vnetConfiguration.infrastructureSubnetId');
}

# Synopsis: Container apps without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.ContainerApp.Naming' -Ref 'AZR-000501' -Type 'Microsoft.App/containerApps' -If { $Configuration['AZURE_CONTAINER_APP_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_CONTAINER_APP_NAME_FORMAT, $True);
}

# Synopsis: Container apps environments without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.ContainerApp.EnvironmentNaming' -Ref 'AZR-000502' -Type 'Microsoft.App/managedEnvironments' -If { $Configuration['AZURE_CONTAINER_APP_ENVIRONMENT_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_CONTAINER_APP_ENVIRONMENT_NAME_FORMAT, $True);
}

# Synopsis: Container apps jobs without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.ContainerApp.JobNaming' -Ref 'AZR-000503' -Type 'Microsoft.App/jobs' -If { $Configuration['AZURE_CONTAINER_APP_JOB_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_CONTAINER_APP_JOB_NAME_FORMAT, $True);
}

#endregion Rules

#region Helper functions

function global:HasIngress {
    [CmdletBinding()]
    param ()
    process {
        $Assert.HasField($TargetObject, 'properties.configuration.ingress').Result
    }
}

#endregion Helper functions
