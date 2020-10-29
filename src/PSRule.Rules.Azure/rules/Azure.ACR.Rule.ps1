# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Container Registry
#

# Synopsis: Use RBAC for delegating access to ACR instead of the registry admin user
Rule 'Azure.ACR.AdminUser' -Type 'Microsoft.ContainerRegistry/registries' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.adminUserEnabled', $False)
}

# Synopsis: ACR should use the Premium or Standard SKU for production deployments
Rule 'Azure.ACR.MinSku' -Type 'Microsoft.ContainerRegistry/registries' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.In($TargetObject, 'Sku.tier', @('Premium', 'Standard'))
}

# Synopsis: Use ACR naming requirements
Rule 'Azure.ACR.Name' -Type 'Microsoft.ContainerRegistry/registries' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcontainerregistry

    # Between 5 and 50 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 5)
    $Assert.LessOrEqual($TargetObject, 'Name', 50)

    # Alphanumerics
    $Assert.Match($TargetObject, 'Name', '^[a-zA-Z0-9]*$')
}

# Synopsis: Consider using quarantining new container images until verified.
Rule 'Azure.ACR.Quarantine' -Type 'Microsoft.ContainerRegistry/registries' -Tag @{ release = 'preview'; ruleSet = '2020_12' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.policies.quarantinePolicy.status', 'enabled');
}

# Synopsis: Consider using content trust for container images.
Rule 'Azure.ACR.ContentTrust' -Type 'Microsoft.ContainerRegistry/registries' -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.policies.trustPolicy.status', 'enabled');
}

# Synopsis: Consider enabling a retention policy to free up untagged manifests.
Rule 'Azure.ACR.Retention' -Type 'Microsoft.ContainerRegistry/registries' -Tag @{ release = 'preview'; ruleSet = '2020_12' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.policies.retentionPolicy.status', 'enabled');
}

# Synopsis: Consider freeing up registry space.
Rule 'Azure.ACR.Usage' -Type 'Microsoft.ContainerRegistry/registries' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $usages = @(GetSubResources -ResourceType 'Microsoft.ContainerRegistry/registries/listUsages' | ForEach-Object {
        $_.value | Where-Object { $_.Name -eq 'Size' }
    });
    if ($usages.Length -gt 0) {
        foreach ($usage in $usages) {
            $Assert.LessOrEqual([int]($usage.currentValue/$usage.limit*100), '.', 90);
        }
    }
}

# Synopsis: Consider enabling vulnerability scanning for container images.
Rule 'Azure.ACR.ContainerScan' -Type 'Microsoft.ContainerRegistry/registries' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $assessments = @(GetSubResources -ResourceType 'Microsoft.Security/assessments');
    $Assert.GreaterOrEqual($assessments, '.', 1).Reason($LocalizedData.AssessmentNotFound);
}

# Synopsis: Consider removing vulnerable container images.
Rule 'Azure.ACR.ImageHealth' -Type 'Microsoft.ContainerRegistry/registries' -If { (IsExport) -and (@(GetSubResources -ResourceType 'Microsoft.Security/assessments')).Length -gt 0 } -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $assessments = @(GetSubResources -ResourceType 'Microsoft.Security/assessments');
    foreach ($assessment in $assessments) {
        $Assert.In($assessment, 'Properties.status.code', @('Healthy', 'NotApplicable')).Reason($LocalizedData.AssessmentUnhealthy);
    }
}

# Synopsis: Consider geo-replicating container images.
Rule 'Azure.ACR.GeoReplica' -Type 'Microsoft.ContainerRegistry/registries' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2020_12' } {
    $replications = @(GetSubResources -ResourceType 'Microsoft.ContainerRegistry/registries/replications');
    $registryLocation = GetNormalLocation -Location $TargetObject.Location;
    foreach ($replica in $replications) {
        $replicaLocation = GetNormalLocation -Location $replica.Location;

        # Compare normalized locations to determine if a replica is in an secondary region
        if ($registryLocation -ne $replicaLocation) {
            return $Assert.Pass();
        }
    }
}
