# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Arc
#

#region Rules

# Synopsis: Deploy Microsoft Defender for Containers extension for Arc-enabled Kubernetes clusters.
Rule 'Azure.Arc.Kubernetes.Defender' -Ref 'AZR-000373' -Type 'Microsoft.Kubernetes/connectedClusters' -Tag @{ release = 'preview'; ruleSet = '2023_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'LT-1' } {
    $defender = @(GetSubResources -ResourceType 'Microsoft.KubernetesConfiguration/extensions' |
        Where-Object { $_.properties.extensionType -eq 'microsoft.azuredefender.kubernetes' })
    $Assert.GreaterOrEqual($defender, '.', 1).Reason($LocalizedData.ArcKubernetesDefender, $PSRule.TargetName)
}

# Synopsis: Use a maintenance configuration for Arc-enabled servers. 
Rule 'Azure.Arc.Server.MaintenanceConfig' -Ref 'AZR-000374' -Type 'Microsoft.HybridCompute/machines' -Tag @{ release = 'preview'; ruleSet = '2023_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $maintenanceConfig = @(GetSubResources -ResourceType 'Microsoft.Maintenance/configurationAssignments' |
        Where-Object { $_.properties.maintenanceConfigurationId })
    $Assert.GreaterOrEqual($maintenanceConfig, '.', 1).Reason($LocalizedData.ArcServerMaintenanceConfig, $PSRule.TargetName)
}

#endregion Rules
