# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Arc
#

#region Rules

# Synopsis: Deploy Microsoft Defender for Containers extension for Arc-enabled Kubernetes clusters.
Rule 'Azure.Arc.Kubernetes.Defender' -Ref 'AZR-000373' -Type 'Microsoft.Kubernetes/connectedClusters' -Tag @{ release = 'Preview'; ruleSet = '2023_06'; } {
    $defender = @(GetSubResources -ResourceType 'Microsoft.KubernetesConfiguration/extensions' |
        Where-Object { $_.properties.extensionType -eq 'microsoft.azuredefender.kubernetes' })
    $Assert.GreaterOrEqual($defender, '.', 1).Reason($LocalizedData.ArcKubernetesDefender, $PSRule.TargetName)
}

#endregion Rules
