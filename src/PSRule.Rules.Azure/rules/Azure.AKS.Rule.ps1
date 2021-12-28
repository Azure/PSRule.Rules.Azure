# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Kubernetes Service (AKS)
#

# Synopsis: AKS clusters should meet the minimum version
Rule 'Azure.AKS.Version' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $minVersion = [Version]$Configuration.Azure_AKSMinimumVersion
    if ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters') {
        $Assert.Create(
            (([Version]$TargetObject.Properties.kubernetesVersion) -ge $minVersion),
            $LocalizedData.AKSVersion,
            $TargetObject.Properties.kubernetesVersion
        );
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters/agentPools') {
        $Assert.NullOrEmpty($TargetObject, 'Properties.orchestratorVersion').Result -or
            (([Version]$TargetObject.Properties.orchestratorVersion) -ge $minVersion)
        Reason ($LocalizedData.AKSVersion -f $TargetObject.Properties.orchestratorVersion);
    }
} -Configure @{ Azure_AKSMinimumVersion = '1.20.5' }

# Synopsis: AKS agent pools should run the same Kubernetes version as the cluster
Rule 'Azure.AKS.PoolVersion' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $clusterVersion = $TargetObject.Properties.kubernetesVersion;
    $agentPools = @(GetAgentPoolProfiles);
    if ($agentPools.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($agentPool in $agentPools) {
        $Assert.HasDefaultValue($agentPool, 'orchestratorVersion', $clusterVersion).
            Reason($LocalizedData.AKSNodePoolVersion, $agentPool.name, $agentPool.orchestratorVersion);
    }
}

# Synopsis: AKS cluster should use role-based access control
Rule 'Azure.AKS.UseRBAC' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.enableRBAC', $True)
}

# Synopsis: AKS node pools should use scale sets
Rule 'Azure.AKS.PoolScaleSet' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $agentPools = @(GetAgentPoolProfiles);
    if ($agentPools.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($agentPool in $agentPools) {
        $Assert.HasFieldValue($agentPool, 'type', 'VirtualMachineScaleSets').
            Reason($LocalizedData.AKSNodePoolType, $agentPool.name);
    }
}

# Synopsis: AKS nodes should use a minimum number of pods
Rule 'Azure.AKS.NodeMinPods' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    $agentPools = @(GetAgentPoolProfiles);
    if ($agentPools.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($agentPool in $agentPools) {
        $Assert.GreaterOrEqual($agentPool, 'maxPods', $Configuration.Azure_AKSNodeMinimumMaxPods);
    }
} -Configure @{ Azure_AKSNodeMinimumMaxPods = 50 }

# Synopsis: Use AKS naming requirements
Rule 'Azure.AKS.Name' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcontainerservice

    # Between 1 and 63 characters long
    $Assert.GreaterOrEqual($PSRule, 'TargetName', 1);
    $Assert.LessOrEqual($PSRule, 'TargetName', 63);

    # Alphanumerics, underscores, and hyphens
    # Start and end with alphanumeric
    $Assert.Match($PSRule, 'TargetName', '^[A-Za-z0-9](-|\w)*[A-Za-z0-9]$');
}

# Synopsis: Use AKS naming requirements for DNS prefix
Rule 'Azure.AKS.DNSPrefix' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_06' } {
    # Between 1 and 54 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Properties.dnsPrefix', 1);
    $Assert.LessOrEqual($TargetObject, 'Properties.dnsPrefix', 54);

    # Alphanumerics and hyphens
    # Start and end with alphanumeric
    $Assert.Match($TargetObject, 'Properties.dnsPrefix', '^[A-Za-z0-9]((-|[A-Za-z0-9]){0,}[A-Za-z0-9]){0,}$');
}

# Synopsis: Use Autoscaling to ensure AKS cluster is running efficiently with the right number of nodes for the workloads present.
Rule 'Azure.AKS.AutoScaling' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    $agentPools = @(GetAgentPoolProfiles);

    if ($agentPools.Length -eq 0) {
        return $Assert.Pass();
    }

    foreach ($agentPool in $agentPools) {

        # Autoscaling only available on virtual machine scale sets
        if ($Assert.HasFieldValue($agentPool, 'type', 'VirtualMachineScaleSets').Result) {
            $Assert.HasFieldValue($agentPool, 'enableAutoScaling', $True).Reason($LocalizedData.AKSAutoScaling, $agentPool.name);
        }
        else {
            $Assert.Pass()
        }
    }
}

# Synopsis: AKS clusters using Azure CNI should use large subnets to reduce IP exhaustion issues.
Rule 'Azure.AKS.CNISubnetSize' -If { IsExport } -With 'Azure.AKS.AzureCNI' -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    $clusterSubnets = @(GetSubResources -ResourceType 'Microsoft.Network/virtualNetworks/subnets');

    if ($clusterSubnets.Length -eq 0) {
        return $Assert.Pass();
    }

    $configurationMinimumSubnetSize = $Configuration.AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE;

    foreach ($subnet in $clusterSubnets) {
        $subnetAddressPrefixSize = [int]$subnet.Properties.addressPrefix.Split('/')[-1];
        
        $Assert.LessOrEqual($subnetAddressPrefixSize, '.', $configurationMinimumSubnetSize).
            Reason(
                $LocalizedData.AKSAzureCNI, 
                $subnet.Name, 
                $configurationMinimumSubnetSize
            );
    }
} -Configure @{ AZURE_AKS_CNI_MINIMUM_CLUSTER_SUBNET_SIZE = 23 }

# Synopsis: AKS clusters deployed with virtual machine scale sets should use availability zones in supported regions for high availability.
Rule 'Azure.AKS.AvailabilityZone' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    $agentPools = @(GetAgentPoolProfiles);

    if ($agentPools.Length -eq 0) {
        return $Assert.Pass();
    }

    $virtualMachineScaleSetProvider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.Compute', 'virtualMachineScaleSets');

    $configurationZoneMappings = $Configuration.AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST;
    $providerZoneMappings = $virtualMachineScaleSetProvider.ZoneMappings;
    $mergedAvailabilityZones = PrependConfigurationZoneWithProviderZone -ConfigurationZone $configurationZoneMappings -ProviderZone $providerZoneMappings;

    $availabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $mergedAvailabilityZones;

    if (-not $availabilityZones) {
        return $Assert.Pass();
    }

    $joinedZoneString = $availabilityZones -join ', ';

    foreach ($agentPool in $agentPools) {

        # Availability zones only available on virtual machine scale sets
        if ($Assert.HasFieldValue($agentPool, 'type', 'VirtualMachineScaleSets').Result) {
            $Assert.HasFieldValue($agentPool, 'availabilityZones').
                Reason($LocalizedData.AKSAvailabilityZone, $agentPool.name, $TargetObject.Location, $joinedZoneString);
        }
        else {
            $Assert.Pass();
        }
    }
} -Configure @{ AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST = @() }

# Synopsis: Enable Container insights to monitor AKS cluster workloads.
Rule 'Azure.AKS.ContainerInsights' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    $Assert.HasFieldValue($TargetObject, 'Properties.addonProfiles.omsAgent.enabled', $True);
}

# Synopsis: AKS clusters should collect security-based audit logs to assess and monitor the compliance status of workloads.
Rule 'Azure.AKS.AuditLogs' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    $diagnosticLogs = @(GetSubResources -ResourceType 'Microsoft.Insights/diagnosticSettings', 'Microsoft.ContainerService/managedClusters/providers/diagnosticSettings');

    $Assert.Greater($diagnosticLogs, '.', 0).Reason($LocalizedData.DiagnosticSettingsNotConfigured, $TargetObject.name);

    foreach ($setting in $diagnosticLogs) {
        $kubeAuditEnabledLog = @($setting.Properties.logs | Where-Object {
            $_.category -in 'kube-audit', 'kube-audit-admin' -and $_.enabled
        });

        $guardEnabledLog = @($setting.Properties.logs | Where-Object {
            $_.category -eq 'guard' -and $_.enabled
        });

        $auditLogsEnabled = $Assert.Greater($kubeAuditEnabledLog, '.', 0).Result -and
                            $Assert.Greater($guardEnabledLog, '.', 0).Result;

        $Assert.Create($auditLogsEnabled, $LocalizedData.AKSAuditLogs, $setting.name);
    }
}

# Synopsis: AKS clusters should collect platform diagnostic logs to monitor the state of workloads.
Rule 'Azure.AKS.PlatformLogs' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2021_09'; } {
    $configurationLogCategoriesList = $Configuration.GetStringValues('AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST');

    if ($configurationLogCategoriesList.Length -eq 0) {
        return $Assert.Pass();
    }

    $diagnosticLogs = @(GetSubResources -ResourceType 'Microsoft.Insights/diagnosticSettings', 'Microsoft.ContainerService/managedClusters/providers/diagnosticSettings');

    $Assert.Greater($diagnosticLogs, '.', 0).Reason($LocalizedData.DiagnosticSettingsNotConfigured, $TargetObject.name);

    $availableLogCategories = @{
        Logs = @(
            'cluster-autoscaler', 
            'kube-apiserver', 
            'kube-controller-manager', 
            'kube-scheduler'
        )
        Metrics = @(
            'AllMetrics'
        )
    }

    $configurationLogCategories = @($configurationLogCategoriesList | Where-Object {
        $_ -in $availableLogCategories.Logs
    });

    $configurationMetricCategories = @($configurationLogCategoriesList | Where-Object {
        $_ -in $availableLogCategories.Metrics
    });

    $logCategoriesNeeded = [System.Math]::Min(
        $configurationLogCategories.Length, 
        $availableLogCategories.Logs.Length
    );

    $metricCategoriesNeeded = [System.Math]::Min(
        $configurationMetricCategories.Length, 
        $availableLogCategories.Metrics.Length
    );

    $logCategoriesJoinedString = $configurationLogCategoriesList -join ', ';

    foreach ($setting in $diagnosticLogs) {
        $platformLogs = @($setting.Properties.logs | Where-Object {
            $_.enabled -and
            $_.category -in $configurationLogCategories -and
            $_.category -in $availableLogCategories.Logs
        });

        $metricLogs = @($setting.Properties.metrics | Where-Object {
            $_.enabled -and 
            $_.category -in $configurationMetricCategories -and
            $_.category -in $availableLogCategories.Metrics
        });

        $platformLogsEnabled = $Assert.HasFieldValue($platformLogs, 'Length', $logCategoriesNeeded).Result -and 
                               $Assert.HasFieldValue($metricLogs, 'Length', $metricCategoriesNeeded).Result

        $Assert.Create(
            $platformLogsEnabled, 
            $LocalizedData.AKSPlatformLogs, 
            $setting.name, 
            $logCategoriesJoinedString
        );
    }
} -Configure @{ 
    AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST = @(
        'cluster-autoscaler', 
        'kube-apiserver', 
        'kube-controller-manager', 
        'kube-scheduler',
        'AllMetrics'
    )
}

#region Helper functions

function global:GetAgentPoolProfiles {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param ()
    process {
        if ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters') {
            $TargetObject.Properties.agentPoolProfiles;
            @(GetSubResources -ResourceType 'Microsoft.ContainerService/managedClusters/agentPools' | ForEach-Object {
                [PSCustomObject]@{
                    name = $_.name
                    type = $_.properties.type
                    maxPods = $_.properties.maxPods
                    orchestratorVersion = $_.properties.orchestratorVersion
                    enableAutoScaling = $_.properties.enableAutoScaling
                    availabilityZones = $_.properties.availabilityZones
                }
            });
        }
        elseif ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters/agentPools') {
            [PSCustomObject]@{
                name = $TargetObject.name
                type = $TargetObject.properties.type
                maxPods = $TargetObject.properties.maxPods
                orchestratorVersion = $TargetObject.properties.orchestratorVersion
                enableAutoScaling = $TargetObject.properties.enableAutoScaling
                availabilityZones = $TargetObject.properties.availabilityZones
            }
        }
    }
}

#endregion Helper functions
