# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Kubernetes Service (AKS)
#

# Synopsis: AKS clusters should have minimum number of nodes for failover and updates
Rule 'Azure.AKS.MinNodeCount' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA' } {
    $TargetObject.Properties.agentPoolProfiles[0].count -ge 3
}

# Synopsis: AKS clusters should meet the minimum version
Rule 'Azure.AKS.Version' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA' } {
    $minVersion = [Version]$Configuration.minAKSVersion
    if ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters') {
        ([Version]$TargetObject.Properties.kubernetesVersion) -ge $minVersion
        Reason ($LocalizedData.AKSVersion -f $TargetObject.Properties.kubernetesVersion);
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters/agentPools') {
        $Assert.NullOrEmpty($TargetObject, 'Properties.orchestratorVersion').Result -or
            (([Version]$TargetObject.Properties.orchestratorVersion) -ge $minVersion)
        Reason ($LocalizedData.AKSVersion -f $TargetObject.Properties.orchestratorVersion);
    }
} -Configure @{ minAKSVersion = '1.16.7' }

# Synopsis: AKS agent pools should run the same Kubernetes version as the cluster
Rule 'Azure.AKS.PoolVersion' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA' } {
    $clusterVersion = $TargetObject.Properties.kubernetesVersion
    foreach ($pool in $TargetObject.Properties.agentPoolProfiles) {
        $result = $Assert.HasDefaultValue($pool, 'orchestratorVersion', $clusterVersion);
        $result.AddReason(($LocalizedData.AKSNodePoolVersion -f $pool.name, $pool.orchestratorVersion));
        $result;
    }
}

# Synopsis: AKS cluster should use role-based access control
Rule 'Azure.AKS.UseRBAC' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.enableRBAC', $True)
}

# Synopsis: AKS clusters should use pod security policies
Rule 'Azure.AKS.PodSecurityPolicy' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'preview' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.enablePodSecurityPolicy', $True)
}

# Synopsis: AKS clusters should use network policies
Rule 'Azure.AKS.NetworkPolicy' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.networkProfile.networkPolicy', 'azure')
}

# Synopsis: AKS node pools should use scale sets
Rule 'Azure.AKS.PoolScaleSet' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA' } {
    $result = $True
    if ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters') {
        $TargetObject.Properties.agentPoolProfiles | ForEach-Object {
            if ($_.type -ne 'VirtualMachineScaleSets') {
                $result = $False
                $Assert.Fail(($LocalizedData.AKSNodePoolType -f $_.name))
            }
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters/agentPools') {
        $result = $TargetObject.Properties.type -eq 'VirtualMachineScaleSets'
        if (!$result) {
            $Assert.Fail(($LocalizedData.AKSNodePoolType -f $TargetObject.name))
        }
    }
    return $result
}

# Synopsis: AKS nodes should use a minimum number of pods
Rule 'Azure.AKS.NodeMinPods' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA' } {
    $agentPools = $Null;
    if ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters') {
        $agentPools = @($TargetObject.Properties.agentPoolProfiles);
        if ($agentPools.Length -eq 0) {
            $True;
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters/agentPools') {
        $agentPools = @($TargetObject.Properties);
    }
    foreach ($agentPool in $agentPools) {
        $Assert.GreaterOrEqual($agentPool, 'maxPods', $Configuration.Azure_AKSNodeMinimumPods)
    }
} -Configure @{ Azure_AKSNodeMinimumPods = 50 }
