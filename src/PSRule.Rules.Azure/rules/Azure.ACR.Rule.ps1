# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Rules for Azure Container Registry (ACR)
#

#region Rules

# Synopsis: Consider freeing up registry space.
Rule 'Azure.ACR.Usage' -Ref 'AZR-000001' -Type 'Microsoft.ContainerRegistry/registries' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2020_12'; method = 'in-flight'; } {
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
Rule 'Azure.ACR.ContainerScan' -Ref 'AZR-000002' -Type 'Microsoft.ContainerRegistry/registries' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2020_12'; method = 'in-flight'; } {
    $assessments = @(GetSubResources -ResourceType 'Microsoft.Security/assessments');
    $Assert.GreaterOrEqual($assessments, '.', 1).Reason($LocalizedData.AssessmentNotFound);
}

# Synopsis: Consider removing vulnerable container images.
Rule 'Azure.ACR.ImageHealth' -Ref 'AZR-000003' -Type 'Microsoft.ContainerRegistry/registries' -If { (IsExport) -and (@(GetSubResources -ResourceType 'Microsoft.Security/assessments')).Length -gt 0 } -Tag @{ release = 'GA'; ruleSet = '2020_12'; method = 'in-flight'; } {
    $assessments = @(GetSubResources -ResourceType 'Microsoft.Security/assessments');
    foreach ($assessment in $assessments) {
        $Assert.In($assessment, 'Properties.status.code', @('Healthy', 'NotApplicable')).Reason($LocalizedData.AssessmentUnhealthy);
    }
}

# Synopsis: Consider geo-replicating container images.
Rule 'Azure.ACR.GeoReplica' -Ref 'AZR-000004' -Type 'Microsoft.ContainerRegistry/registries' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2020_12'; method = 'in-flight'; } {
    $replications = @(GetSubResources -ResourceType 'Microsoft.ContainerRegistry/registries/replications');
    $registryLocation = GetNormalLocation -Location $TargetObject.Location;
    foreach ($replica in $replications) {
        $replicaLocation = GetNormalLocation -Location $replica.Location;

        # Compare normalized locations to determine if a replica is in an secondary region
        if ($registryLocation -ne $replicaLocation) {
            return $Assert.Pass();
        }
    }
    return $Assert.Fail($LocalizedData.ReplicaNotFound);
}

# Synopsis: Azure Container Registries should have soft delete policy enabled.
Rule 'Azure.ACR.SoftDelete' -Ref 'AZR-000310' -Type 'Microsoft.ContainerRegistry/registries' -If { GetACRSoftDeletePreviewLimitations } -Tag @{ release = 'Preview'; ruleSet = '2022_09'; } {
    $Assert.HasFieldValue($TargetObject, 'properties.policies.softDeletePolicy.status', 'enabled').Reason($LocalizedData.ACRSoftDeletePolicy, $TargetObject.name)
    $Assert.HasFieldValue($TargetObject, 'properties.policies.softDeletePolicy.retentionDays').Reason($LocalizedData.ACRSoftDeletePolicyRetention, $TargetObject.name)
}

#endregion Rules

#region Helper functions

function global:GetACRSoftDeletePreviewLimitations {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        $notGeoReplica = @(GetSubResources -ResourceType 'Microsoft.ContainerRegistry/registries/replications')
        $notRetentionPolicy = $Assert.HasDefaultValue($TargetObject, 'properties.policies.retentionPolicy.status', 'disabled').Result
        ($notGeoReplica.Count -eq 0) -and ($notRetentionPolicy -eq $true)
    }   
}

#endregion Helper functions
