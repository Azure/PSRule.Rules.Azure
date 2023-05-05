# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Arc
#

#region Rules

# Synopsis: Use a maintenance configuration for Arc-enabled servers. 
Rule 'Azure.Arc.Server.MaintenanceConfig' -Ref 'AZR-000374' -Type 'Microsoft.HybridCompute/machines' -Tag @{ release = 'Preview'; ruleSet = '2023_06'; } {
    $maintenanceConfig = @(GetSubResources -ResourceType 'Microsoft.Maintenance/configurationAssignments' |
        Where-Object { $_.properties.maintenanceConfigurationId })
    $Assert.GreaterOrEqual($maintenanceConfig, '.', 1).Reason($LocalizedData.SubResourceNotFound, 'Microsoft.Maintenance/configurationAssignments')
}

#endregion Rules
