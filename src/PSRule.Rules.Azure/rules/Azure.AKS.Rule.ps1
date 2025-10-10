# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Kubernetes Service (AKS)
#

# Synopsis: AKS control plane and nodes pools should use a current stable release.
Rule 'Azure.AKS.Version' -Ref 'AZR-000015' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Reliability'; } -Labels @{ 'Azure.MCSB.v1/control' = 'PV-7' } {
    $minVersion = $Configuration.GetValueOrDefault('Azure_AKSMinimumVersion', $Configuration.AZURE_AKS_CLUSTER_MINIMUM_VERSION);
    if ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters') {
        $upgradeChannel = $TargetObject.properties.autoUpgradeProfile.upgradeChannel
        $expectedUpgradeChannels = @('rapid', 'stable')
        if ($upgradeChannel -in $expectedUpgradeChannels -and !(IsExport)) {
            $Assert.Pass();
        }
        else {
            $Assert.Version($TargetObject, 'Properties.kubernetesVersion', ">=$minVersion");
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters/agentPools') {
        if (!$Assert.HasField($TargetObject, 'Properties.orchestratorVersion').Result) {
            $Assert.Pass();
        }
        else {
            $Assert.Version($TargetObject, 'Properties.orchestratorVersion', ">=$minVersion");
        }
    }
}

# Synopsis: AKS agent pools should run the same Kubernetes version as the cluster
Rule 'Azure.AKS.PoolVersion' -Ref 'AZR-000016' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
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


# Synopsis: AKS node pools should use scale sets
Rule 'Azure.AKS.PoolScaleSet' -Ref 'AZR-000017' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Performance Efficiency'; } {
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
Rule 'Azure.AKS.NodeMinPods' -Ref 'AZR-000018' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Performance Efficiency'; } {
    $minMaxPods = $Configuration.GetValueOrDefault('Azure_AKSNodeMinimumMaxPods', $Configuration.AZURE_AKS_POOL_MINIMUM_MAXPODS);
    $agentPools = @(GetAgentPoolProfiles);
    if ($agentPools.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($agentPool in $agentPools) {
        $Assert.GreaterOrEqual($agentPool, 'maxPods', $minMaxPods);
    }
}

# Synopsis: Use Autoscaling to ensure AKS cluster is running efficiently with the right number of nodes for the workloads present.
Rule 'Azure.AKS.AutoScaling' -Ref 'AZR-000019' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA'; ruleSet = '2021_09'; 'Azure.WAF/pillar' = 'Performance Efficiency'; } {
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
Rule 'Azure.AKS.CNISubnetSize' -Ref 'AZR-000020' -If { IsExport } -With 'Azure.AKS.AzureCNI' -Tag @{ release = 'GA'; ruleSet = '2021_09'; 'Azure.WAF/pillar' = 'Reliability'; } {
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
Rule 'Azure.AKS.AvailabilityZone' -Ref 'AZR-000021' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2021_09'; 'Azure.WAF/pillar' = 'Reliability'; } {
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

# Synopsis: AKS clusters should collect security-based audit logs to assess and monitor the compliance status of workloads.
Rule 'Azure.AKS.AuditLogs' -Ref 'AZR-000022' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2021_09'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'LT-4'; 'Azure.WAF/maturity' = 'L1'; } {
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
Rule 'Azure.AKS.PlatformLogs' -Ref 'AZR-000023' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2021_09'; 'Azure.WAF/pillar' = 'Operational Excellence'; } -Labels @{ 'Azure.MCSB.v1/control' = 'LT-4' } {
    $configurationLogCategoriesList = $Configuration.GetStringValues('AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST');

    if ($configurationLogCategoriesList.Length -eq 0) {
        return $Assert.Pass();
    }

    $diagnosticLogs = @(GetSubResources -ResourceType 'Microsoft.Insights/diagnosticSettings', 'Microsoft.ContainerService/managedClusters/providers/diagnosticSettings');

    $Assert.Greater($diagnosticLogs, '.', 0).Reason($LocalizedData.DiagnosticSettingsNotConfigured, $TargetObject.name);

    $availableLogCategories = @{
        Logs    = @(
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

# Synopsis: AKS clusters should have minimum number of nodes for failover and updates.
Rule 'Azure.AKS.MinNodeCount' -Ref 'AZR-000024' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Reliability' } {
    $systemNodeCount = 0;
    foreach ($agentPool in @(GetAgentPoolProfiles)) {
        if ($agentPool.mode -ne 'user') {
            if ($agentPool.minCount -gt 0) {
                $systemNodeCount += $agentPool.minCount
            }
            elseif ($agentPool.count -gt 0) {
                $systemNodeCount += $agentPool.count
            }
        }
    };
    $minNodeCount = $Configuration.GetIntegerOrDefault('AZURE_AKS_CLUSTER_MINIMUM_SYSTEM_NODES', 3);
    $Assert.GreaterOrEqual($systemNodeCount, '.', $minNodeCount).PathPrefix('properties.agentPoolProfiles');
}

# Synopsis: AKS user node pools should have a minimum number of nodes for failover and updates.
Rule 'Azure.AKS.MinUserPoolNodes' -Ref 'AZR-000412' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA'; ruleSet = '2024_03'; 'Azure.WAF/pillar' = 'Reliability' } {
    $excludedPools = $Configuration.GetStringValues('AZURE_AKS_CLUSTER_USER_POOL_EXCLUDED_FROM_MINIMUM_NODES');
    $agentPools = @(GetAgentPoolProfiles | Where-Object {
            $_.mode -eq 'user' -and $_.name -notin $excludedPools -and $_.scaleSetPriority -ne 'Spot'
        })

    if ($agentPools.Length -eq 0) {
        return $Assert.Pass();
    }

    $minNodeCount = $Configuration.GetIntegerOrDefault('AZURE_AKS_CLUSTER_USER_POOL_MINIMUM_NODES', 3);
    foreach ($agentPool in $agentPools) {
        $nodeCount = 0;
        if ($agentPool.minCount -gt 0) {
            $nodeCount = $agentPool.minCount
        }
        elseif ($agentPool.count -gt 0) {
            $nodeCount = $agentPool.count
        }
        $Assert.GreaterOrEqual($nodeCount, '.', $minNodeCount).PathPrefix('properties.agentPoolProfiles');
    }
}

# Synopsis: AKS clusters should have Uptime SLA enabled to ensure availability of control plane components for production workloads.
Rule 'Azure.AKS.UptimeSLA' -Ref 'AZR-000285' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2022_09'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $priorApi = $Assert.APIVersion($TargetObject, 'apiVersion', '<2023-02-01', $True).Result
    if ($priorApi) {
        $Assert.Contains($TargetObject, 'sku.tier', 'Paid')
    }
    else {
        $Assert.Contains($TargetObject, 'sku.tier', 'Standard')  
    }
}

# Synopsis: AKS clusters should use ephemeral OS disks which can provide lower read/write latency, along with faster node scaling and cluster upgrades.
Rule 'Azure.AKS.EphemeralOSDisk' -Ref 'AZR-000287' -Level Warning -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -Tag @{ release = 'GA'; ruleSet = '2022_09'; 'Azure.WAF/pillar' = 'Performance Efficiency'; } {
    $agentPools = @(GetAgentPoolProfiles);
    if ($agentPools.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($agentPool in $agentPools) {
        $Assert.HasDefaultValue($agentPool, 'osDiskType', 'Ephemeral').
        ReasonIf($agentPool.osDiskType, $LocalizedData.AKSEphemeralOSDiskNotConfigured);
    }
}

# Synopsis: Use kube-audit-admin instead of kube-audit to capture administrative actions in AKS clusters.
Rule 'Azure.AKS.AuditAdmin' -Ref 'AZR-000445' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2024_09'; 'Azure.WAF/pillar' = 'Cost Optimization'; } {
    $kubeAuditLogs = @(GetSubResources -ResourceType 'Microsoft.Insights/diagnosticSettings' |
        Where-Object { $_.properties.logs | Where-Object { $_.category -eq 'kube-audit' -and $_.enabled } } )

    if ($kubeAuditLogs.Count -eq 0) {
        return $Assert.Pass()
    }

    foreach ($kubeAuditLog in $kubeAuditLogs) {
        $Assert.Fail().Reason($LocalizedData.AKSAuditAdmin, $kubeAuditLog.name)
    }
}

# Synopsis: Configure customer-controlled maintenance windows for AKS clusters.
Rule 'Azure.AKS.MaintenanceWindow' -Ref 'AZR-000446' -Type 'Microsoft.ContainerService/managedClusters' -Tag @{ release = 'GA'; ruleSet = '2024_09'; 'Azure.WAF/pillar' = 'Reliability'; } {
      $maintenanceConfigs = @(GetSubResources -ResourceType 'Microsoft.ContainerService/managedClusters/maintenanceConfigurations')
      
      $hasAutoUpgrade = $false
      $hasNodeUpgrade = $false

      foreach ($config in $maintenanceConfigs) {
          if ($config.name -match 'aksManagedAutoUpgradeSchedule$') {
              $hasAutoUpgrade = $true
          }
          elseif ($config.name -match 'aksManagedNodeOSUpgradeSchedule$') {
              $hasNodeUpgrade = $true
          }
      }

      if ($hasAutoUpgrade -and $hasNodeUpgrade) {
          return $Assert.Pass()
      }
      else {
          $Assert.Fail().Reason($LocalizedData.AKSMaintenanceWindow, $PSRule.TargetName)
      }
}

# Synopsis: AKS clusters without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.AKS.Naming' -Ref 'AZR-000498' -Type 'Microsoft.ContainerService/managedClusters' -If { $Configuration['AZURE_AKS_CLUSTER_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $Assert.Match($PSRule, 'TargetName', $Configuration.AZURE_AKS_CLUSTER_NAME_FORMAT, $True);
}

# Synopsis: AKS system node pools without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.AKS.SystemPoolNaming' -Ref 'AZR-000499' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -If { $Configuration['AZURE_AKS_SYSTEM_POOL_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $agentPools = @(GetAgentPoolProfiles | Where-Object { $_.mode -eq 'System' });
    if ($agentPools.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($agentPool in $agentPools) {
        $Assert.Match($agentPool, 'name', $Configuration.AZURE_AKS_SYSTEM_POOL_NAME_FORMAT, $True);
    }
}

# Synopsis: AKS user node pools without a standard naming convention may be difficult to identify and manage.
Rule 'Azure.AKS.UserPoolNaming' -Ref 'AZR-000500' -Type 'Microsoft.ContainerService/managedClusters', 'Microsoft.ContainerService/managedClusters/agentPools' -If { $Configuration['AZURE_AKS_USER_POOL_NAME_FORMAT'] -ne '' } -Tag @{ release = 'GA'; ruleSet = '2025_12'; 'Azure.WAF/pillar' = 'Operational Excellence' } -Labels @{ 'Azure.CAF' = 'naming' } {
    $agentPools = @(GetAgentPoolProfiles | Where-Object { $_.mode -eq 'User' });
    if ($agentPools.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($agentPool in $agentPools) {
        $Assert.Match($agentPool, 'name', $Configuration.AZURE_AKS_USER_POOL_NAME_FORMAT, $True);
    }
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
                        name                = $_.name
                        type                = $_.properties.type
                        mode                = $_.properties.mode
                        maxPods             = $_.properties.maxPods
                        orchestratorVersion = $_.properties.orchestratorVersion
                        enableAutoScaling   = $_.properties.enableAutoScaling
                        availabilityZones   = $_.properties.availabilityZones
                        osDiskType          = $_.properties.osDiskType
                        count               = [int]$_.properties.count
                        minCount            = [int]$_.properties.minCount
                        maxCount            = [int]$_.properties.maxCount
                        scaleSetPriority    = $_.properties.scaleSetPriority
                    }
                });
        }
        elseif ($PSRule.TargetType -eq 'Microsoft.ContainerService/managedClusters/agentPools') {
            [PSCustomObject]@{
                name                = $TargetObject.name
                type                = $TargetObject.properties.type
                mode                = $TargetObject.properties.mode
                maxPods             = $TargetObject.properties.maxPods
                orchestratorVersion = $TargetObject.properties.orchestratorVersion
                enableAutoScaling   = $TargetObject.properties.enableAutoScaling
                availabilityZones   = $TargetObject.properties.availabilityZones
                osDiskType          = $TargetObject.properties.osDiskType
                count               = [int]$TargetObject.properties.count
                minCount            = [int]$TargetObject.properties.minCount
                maxCount            = [int]$TargetObject.properties.maxCount
                scaleSetPriority    = $TargetObject.properties.scaleSetPriority
            }
        }
    }
}

#endregion Helper functions
