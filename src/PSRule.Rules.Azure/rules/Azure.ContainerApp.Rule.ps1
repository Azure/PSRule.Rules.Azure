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
