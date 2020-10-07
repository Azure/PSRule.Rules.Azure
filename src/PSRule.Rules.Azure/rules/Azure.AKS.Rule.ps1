# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Kubernetes Service (AKS)
#

if ($Null -ne $Configuration.minAKSVersion) {
    Write-Warning -Message ($LocalizedData.ConfigurationOptionReplaced -f 'minAKSVersion', 'Azure_AKSMinimumVersion');
}

# Synopsis: AKS clusters should have minimum number of nodes for failover and updates
Rule 'Azure.AKS.MinNodeCount' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.GreaterOrEqual($TargetObject, 'Properties.agentPoolProfiles[0].count', 3);
}

# Synopsis: AKS clusters should meet the minimum version
Rule 'Azure.AKS.Version' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $minVersion = [Version]$Configuration.Azure_AKSMinimumVersion
    if ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters') {
        ([Version]$TargetObject.Properties.kubernetesVersion) -ge $minVersion
        Reason ($LocalizedData.AKSVersion -f $TargetObject.Properties.kubernetesVersion);
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters/agentPools') {
        $Assert.NullOrEmpty($TargetObject, 'Properties.orchestratorVersion').Result -or
            (([Version]$TargetObject.Properties.orchestratorVersion) -ge $minVersion)
        Reason ($LocalizedData.AKSVersion -f $TargetObject.Properties.orchestratorVersion);
    }
} -Configure @{ Azure_AKSMinimumVersion = '1.18.8' }

# Synopsis: AKS agent pools should run the same Kubernetes version as the cluster
Rule 'Azure.AKS.PoolVersion' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $clusterVersion = $TargetObject.Properties.kubernetesVersion
    foreach ($pool in $TargetObject.Properties.agentPoolProfiles) {
        $Assert.
            HasDefaultValue($pool, 'orchestratorVersion', $clusterVersion).
            Reason($LocalizedData.AKSNodePoolVersion, $pool.name, $pool.orchestratorVersion)
    }
}

# Synopsis: AKS cluster should use role-based access control
Rule 'Azure.AKS.UseRBAC' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.enableRBAC', $True)
}

# Synopsis: AKS clusters should use network policies
Rule 'Azure.AKS.NetworkPolicy' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.networkProfile.networkPolicy', 'azure')
}

# Synopsis: AKS node pools should use scale sets
Rule 'Azure.AKS.PoolScaleSet' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
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
Rule 'Azure.AKS.NodeMinPods' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
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
        $Assert.GreaterOrEqual($agentPool, 'maxPods', $Configuration.Azure_AKSNodeMinimumMaxPods)
    }
} -Configure @{ Azure_AKSNodeMinimumMaxPods = 50 }

# Synopsis: Use AKS naming requirements
Rule 'Azure.AKS.Name' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcontainerservice

    # Between 1 and 63 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 1)
    $Assert.LessOrEqual($TargetObject, 'Name', 63)

    # Alphanumerics, underscores, and hyphens
    # Start and end with alphanumeric
    $Assert.Match($TargetObject, 'Name', '^[A-Za-z0-9](-|\w)*[A-Za-z0-9]$')
}

# Synopsis: Use AKS naming requirements for DNS prefix
Rule 'Azure.AKS.DNSPrefix' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # Between 1 and 54 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Properties.dnsPrefix', 1)
    $Assert.LessOrEqual($TargetObject, 'Properties.dnsPrefix', 54)

    # Alphanumerics and hyphens
    # Start and end with alphanumeric
    $Assert.Match($TargetObject, 'Properties.dnsPrefix', '^[A-Za-z0-9]((-|[A-Za-z0-9]){0,}[A-Za-z0-9]){0,}$')
}

# Synopsis: Configure AKS clusters to use managed identities for managing cluster infrastructure.
Rule 'Azure.AKS.ManagedIdentity' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.In($TargetObject, 'Identity.Type', @('SystemAssigned', 'UserAssigned'));
}

# Synopsis: Use a Standard load-balancer with AKS clusters
Rule 'Azure.AKS.StandardLB' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.networkProfile.loadBalancerSku', 'standard')
}

# Synopsis: AKS clusters should use Azure Policy add-on
Rule 'Azure.AKS.AzurePolicyAddOn' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.addonProfiles.azurePolicy.enabled', $True)
}
