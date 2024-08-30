# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Virtual Machines
#

#region Virtual machine

# Synopsis: Virtual machines should use managed disks
Rule 'Azure.VM.UseManagedDisks' -Ref 'AZR-000238' -Type 'Microsoft.Compute/virtualMachines' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-4'; 'Azure.Policy/id' = '/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d' } {
    # Check OS disk
    $Assert.
    NullOrEmpty($TargetObject, 'properties.storageProfile.osDisk.vhd.uri').
    WithReason(($LocalizedData.UnmanagedDisk -f $TargetObject.properties.storageProfile.osDisk.name), $True);

    # Check data disks
    foreach ($dataDisk in $TargetObject.properties.storageProfile.dataDisks) {
        $Assert.
        NullOrEmpty($dataDisk, 'vhd.uri').
        WithReason(($LocalizedData.UnmanagedDisk -f $dataDisk.name), $True);
    }
}

# Synopsis: Check disk caching is configured correctly for the workload
Rule 'Azure.VM.DiskCaching' -Ref 'AZR-000242' -Type 'Microsoft.Compute/virtualMachines' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Performance Efficiency'; } {
    # Check OS disk
    $Assert.HasFieldValue($TargetObject, 'properties.storageProfile.osDisk.caching', 'ReadWrite');

    # Check data disks
    $dataDisks = @($TargetObject.properties.storageProfile.dataDisks | Where-Object {
            $Null -ne $_
        })
    if ($dataDisks.Length -gt 0) {
        foreach ($disk in $dataDisks) {
            if ($disk.managedDisk.storageAccountType -eq 'Premium_LRS') {
                $Assert.HasFieldValue($disk, 'caching', 'ReadOnly');
            }
            else {
                $Assert.HasFieldValue($disk, 'caching', 'None');
            }
        }
    }
}

# Synopsis: Use Hybrid Use Benefit
Rule 'Azure.VM.UseHybridUseBenefit' -Ref 'AZR-000243' -If { (SupportsHybridUse) -and $Configuration.GetBoolOrDefault('AZURE_VM_USE_AZURE_HYBRID_BENEFIT', $False) } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Cost Optimization'; } {
    $Assert.HasFieldValue($TargetObject, 'properties.licenseType', 'Windows_Server');
}

# Synopsis: Use accelerated networking for supported operating systems and VM types.
Rule 'Azure.VM.AcceleratedNetworking' -Ref 'AZR-000244' -If { SupportsAcceleratedNetworking } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Performance Efficiency'; } {
    $resources = @(GetSubResources -ResourceType 'Microsoft.Network/networkInterfaces');
    if ($resources.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($interface in $resources) {
        $Assert.HasFieldValue($interface, 'Properties.enableAcceleratedNetworking', $True);
    }
}

# Synopsis: Linux VMs should use public key pair
Rule 'Azure.VM.PublicKey' -Ref 'AZR-000245' -If { VMHasLinuxOS } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $Assert.HasFieldValue($TargetObject, 'Properties.osProfile.linuxConfiguration.disablePasswordAuthentication', $True)
}

# Synopsis: Ensure that the VM agent is provisioned automatically
Rule 'Azure.VM.Agent' -Ref 'AZR-000246' -Type 'Microsoft.Compute/virtualMachines' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $Assert.HasDefaultValue($TargetObject, 'Properties.osProfile.linuxConfiguration.provisionVMAgent', $True)
    $Assert.HasDefaultValue($TargetObject, 'Properties.osProfile.windowsConfiguration.provisionVMAgent', $True)
}

# Synopsis: Ensure automatic updates are enabled at deployment
Rule 'Azure.VM.Updates' -Ref 'AZR-000247' -Type 'Microsoft.Compute/virtualMachines' -If { IsWindowsOS } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'ES-3' } {
    $Assert.HasDefaultValue($TargetObject, 'Properties.osProfile.windowsConfiguration.enableAutomaticUpdates', $True)
}

# Synopsis: Use VM naming requirements
Rule 'Azure.VM.Name' -Ref 'AZR-000248' -Type 'Microsoft.Compute/virtualMachines' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute

    # Between 1 and 64 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 1)
    $Assert.LessOrEqual($TargetObject, 'Name', 64)

    # Alphanumerics, underscores, periods, and hyphens
    # Start with alphanumeric
    # End with alphanumeric or underscore
    Match 'Name' '^[A-Za-z0-9]((-|\.)*\w){0,79}$'
}

# Synopsis: Use VM naming requirements
Rule 'Azure.VM.ComputerName' -Ref 'AZR-000249' -Type 'Microsoft.Compute/virtualMachines' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute

    $maxLength = 64
    $matchExpression = '^[A-Za-z0-9]([A-Za-z0-9-.]){0,63}$'
    if (IsWindowsOS) {
        $maxLength = 15

        # Alphanumeric or hyphens
        # Can not include only numbers
        $matchExpression = '^[A-Za-z0-9-]{0,14}[A-Za-z-][A-Za-z0-9-]{0,14}$'
    }

    # Between 1 and 15/ 64 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Properties.osProfile.computerName', 1)
    $Assert.LessOrEqual($TargetObject, 'Properties.osProfile.computerName', $maxLength)

    # Alphanumerics and hyphens
    # Start and end with alphanumeric
    Match 'Properties.osProfile.computerName' $matchExpression
}

#endregion Virtual machine

#region Managed Disks

# Synopsis: Managed disks should be attached to virtual machines
Rule 'Azure.VM.DiskAttached' -Ref 'AZR-000250' -Type 'Microsoft.Compute/disks' -If { ($TargetObject.ResourceName -notlike '*-ASRReplica') -and (IsExport) } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Cost Optimization'; } {
    # Disks should be attached unless they are used by ASR, which are not attached until fail over
    # Disks for VMs that are off are marked as Reserved
    Within 'properties.diskState' 'Attached', 'Reserved' -Reason $LocalizedData.ResourceNotAssociated
}

# Synopsis: Align to the Managed Disk billing increments to improve cost efficiency.
Rule 'Azure.VM.DiskSizeAlignment' -Ref 'AZR-000251' -Type 'Microsoft.Compute/disks' -With 'Azure.Disk.NonMarketplaceImage' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Cost Optimization'; } {
    $diskSize = @(32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768)

    # Add smaller disk sizes for premium and standard SSD.
    if ($TargetObject.sku.name -like 'Premium_*' -or $TargetObject.sku.name -like 'StandardSSD_*') {
        $diskSize = @(4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768)
    }

    # Add sizes for Ultra SSD.
    if ($TargetObject.sku.name -like 'UltraSSD_*') {
        $diskSize = @(4, 8, 16, 32, 64, 128, 256, 512)
        1..64 | ForEach-Object { $diskSize += $_ * 1024 }
    }

    $actualSize = $TargetObject.Properties.diskSizeGB

    # Find the closest disk size.
    $i = 0;
    while ($actualSize -gt $diskSize[$i]) {
        $i++;
    }

    # Actual disk size should be the disk size within 5GB.
    $Assert.GreaterOrEqual($TargetObject, 'Properties.diskSizeGB', ($diskSize[$i] - 5));
}

# Synopsis: Use Azure Disk Encryption
Rule 'Azure.VM.ADE' -Ref 'AZR-000252' -Type 'Microsoft.Compute/disks' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-3' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.encryptionSettingsCollection.enabled', $True)
    $Assert.HasFieldValue($TargetObject, 'Properties.encryptionSettingsCollection.encryptionSettings')
}

# Synopsis: Use Managed Disk naming requirements
Rule 'Azure.VM.DiskName' -Ref 'AZR-000253' -Type 'Microsoft.Compute/disks' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute

    # Between 1 and 80 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 1)
    $Assert.LessOrEqual($TargetObject, 'Name', 80)

    # Alphanumerics, underscores, periods, and hyphens
    # Start with alphanumeric
    # End with alphanumeric or underscore
    Match 'Name' '^[A-Za-z0-9]((-|\.)*\w){0,79}$'
}

#endregion Managed Disks

#region Availability set

# Synopsis: Availability sets should be deployed with at least two members
Rule 'Azure.VM.ASMinMembers' -Ref 'AZR-000255' -Type 'Microsoft.Compute/availabilitySets' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $Assert.GreaterOrEqual($TargetObject, 'properties.virtualMachines', 2)
}

# Synopsis: Use Availability Set naming requirements
Rule 'Azure.VM.ASName' -Ref 'AZR-000256' -Type 'Microsoft.Compute/availabilitySets' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute

    # Between 1 and 80 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 1)
    $Assert.LessOrEqual($TargetObject, 'Name', 80)

    # Alphanumerics, underscores, periods, and hyphens
    # Start with alphanumeric
    # End with alphanumeric or underscore
    Match 'Name' '^[A-Za-z0-9]((-|\.)*\w){0,79}$'
}

#endregion Availability set

#region Proximity Placement Groups

# Synopsis: Use Proximity Placement Groups naming requirements
Rule 'Azure.VM.PPGName' -Ref 'AZR-000260' -Type 'Microsoft.Compute/proximityPlacementGroups' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    # https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute

    # Between 1 and 80 characters long
    $Assert.GreaterOrEqual($TargetObject, 'Name', 1)
    $Assert.LessOrEqual($TargetObject, 'Name', 80)

    # Alphanumerics, underscores, periods, and hyphens
    # Start and end with alphanumeric
    Match 'Name' '^[A-Za-z0-9]((-|\.|_)*[A-Za-z0-9]){0,79}$'
}

#endregion Proximity Placement Groups

# Synopsis: Protect Custom Script Extensions commands
Rule 'Azure.VM.ScriptExtensions' -Ref 'AZR-000332' -Type 'Microsoft.Compute/virtualMachines', 'Microsoft.Compute/virtualMachines/extensions' -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Security'; } {
    $vmConfig = @($TargetObject);

    if ($PSRule.TargetType -eq 'Microsoft.Compute/virtualMachines') {
        $vmConfig = @(GetSubResources -ResourceType 'extensions', 'Microsoft.Compute/virtualMachines/extensions' );
    }

    if ($vmConfig.Length -eq 0) {
        return $Assert.Pass();
    }

    ## Extension Prof
    $customScriptProperties = @('CustomScript', 'CustomScriptExtension', 'CustomScriptForLinux')
    foreach ($config in $vmConfig) {
        if ($config.properties.type -in $customScriptProperties) {
            $cleanValue = [PSRule.Rules.Azure.Runtime.Helper]::CompressExpression($config.properties.settings.commandToExecute);
            $Assert.NotMatch($cleanValue, '.', "SecretReference")
        }
        else {
            return $Assert.Pass();
        }
    }
}

#region Azure Monitor Agent

# Synopsis: Use Azure Monitor Agent as replacement for Log Analytics Agent.
Rule 'Azure.VM.MigrateAMA' -Ref 'AZR-000317' -Type 'Microsoft.Compute/virtualMachines' -If { HasOMSOrAMAExtension } -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $extensions = @(GetSubResources -ResourceType 'Microsoft.Compute/virtualMachines/extensions' |
        Where-Object { (($_.Properties.publisher -eq 'Microsoft.EnterpriseCloud.Monitoring') -and ($_.Properties.type -eq 'MicrosoftMonitoringAgent')) -or
            (($_.Properties.publisher -eq 'Microsoft.EnterpriseCloud.Monitoring') -and ($_.Properties.type -eq 'OmsAgentForLinux')) })

    $Assert.Less($extensions, '.', 1).Reason($LocalizedData.LogAnalyticsAgentDeprecated).PathPrefix('resources')
}

#endregion Azure Monitor Agent

#region IaaS SQL Server disks

# Synopsis: Use Premium SSD disks or greater for data and log files for production SQL Server workloads.
Rule 'Azure.VM.SQLServerDisk' -Ref 'AZR-000324' -Type 'Microsoft.Compute/virtualMachines' -If { HasPublisherMicrosoftSQLServer } -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Performance Efficiency'; } {
    $disks = @(GetOSAndDataDisks)
    $Assert.Less($disks, '.', 1).Reason($LocalizedData.SQLServerVMDisks).
    PathPrefix('properties.storageProfile')
}

#endregion IaaS SQL Server disks

#region Azure Monitor Agent

# Synopsis: Use Azure Monitor Agent for collecting monitoring data.
Rule 'Azure.VM.AMA' -Ref 'AZR-000345' -Type 'Microsoft.Compute/virtualMachines' -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $amaTypes = @('AzureMonitorWindowsAgent', 'AzureMonitorLinuxAgent')
    $extensions = @(GetSubResources -ResourceType 'Microsoft.Compute/virtualMachines/extensions' |
        Where-Object { $_.properties.publisher -eq 'Microsoft.Azure.Monitor' -or $_.properties.type -in $amaTypes })
    
    $Assert.GreaterOrEqual($extensions, '.', 1).
    Reason($LocalizedData.VMAzureMonitorAgent).PathPrefix('resources')
}

#endregion Azure Monitor Agent

#region Maintenance Configuration

# Synopsis: Use a maintenance configuration for virtual machines.
Rule 'Azure.VM.MaintenanceConfig' -Ref 'AZR-000375' -Type 'Microsoft.Compute/virtualMachines' -Tag @{ release = 'GA'; ruleSet = '2024_06'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $maintenanceConfig = @(GetSubResources -ResourceType 'Microsoft.Maintenance/configurationAssignments' |
        Where-Object { $_.properties.maintenanceConfigurationId })
    $Assert.GreaterOrEqual($maintenanceConfig, '.', 1).Reason($LocalizedData.VMMaintenanceConfig, $PSRule.TargetName)
}

#endregion Maintenance Configuration

#region Public IP

# Synopsis: Avoid attaching public IPs directly to virtual machines.
Rule 'Azure.VM.PublicIPAttached' -Ref 'AZR-000449' -Type 'Microsoft.Network/networkInterfaces' -Tag @{ release = 'GA'; ruleSet = '2024_09'; 'Azure.WAF/pillar' = 'Security'; } {
    $configurations = @($TargetObject.properties.ipConfigurations)

    if ($configurations.Count -eq 0) {
        return $Assert.Pass()
    }

    foreach ($config in $configurations) {
        $Assert.HasDefaultValue($config, 'properties.publicIPAddress.id', $null).Reason($LocalizedData.VMPublicIPAttached, $PSRule.TargetName)
    }
}

#endregion Public IP

#region Multitenant Hosting Rights

# Synopsis: Deploy Windows 10 and 11 virtual machines in Azure using Multitenant Hosting Rights to leverage your existing Windows licenses.
Rule 'Azure.VM.MultiTenantHosting' -Ref 'AZR-000452' -Type 'Microsoft.Compute/virtualMachines' -If { $Configuration.GetBoolOrDefault('AZURE_VM_USE_MULTI_TENANT_HOSTING_RIGHTS', $False) } -Tag @{ release = 'GA'; ruleSet = '2024_09'; 'Azure.WAF/pillar' = 'Cost Optimization'; } {
    if (($TargetObject.properties.storageProfile.imageReference.publisher -ne 'MicrosoftWindowsDesktop' -and
            $TargetObject.properties.storageProfile.imageReference.offer -notmatch 'windows-10|windows-11') -or $TargetObject.Properties.storageProfile.osDisk.osType -ne 'Windows') {
        
        return $Assert.Pass()
    }

    $Assert.HasFieldValue($TargetObject, 'properties.licenseType', 'Windows_Client').Reason($LocalizedData.VMMultiTenantHostingRights, $PSRule.TargetName)
}

#endregion Multitenant Hosting Rights

#region Availability Set

# Synopsis: Ensure high availability by distributing traffic among members in an availability set.
Rule 'Azure.VM.ASDistributeTraffic' -Ref 'AZR-000451' -Type 'Microsoft.Compute/virtualMachines' -If { IsExport } -Tag @{ release = 'GA'; ruleSet = '2024_09'; 'Azure.WAF/pillar' = 'Reliability'; } {
    if (-not $TargetObject.properties.availabilitySet.id) {
        return $Assert.Pass()
    }

    $configurations = @(GetSubResources -ResourceType 'Microsoft.Network/networkInterfaces' | ForEach-Object { $_.properties.ipConfigurations }) | Where-Object { $null -ne $_ }

    if ($configurations.Count -eq 0) {
        return $Assert.Pass()
    }

    foreach ($config in $configurations) {
        $result = @($config | Where-Object { $_.properties.applicationGatewayBackendAddressPools.id -or $_.properties.loadBalancerBackendAddressPools.id })

        if ($result.Count -eq 0) { $Assert.Fail().Reason($LocalizedData.VMAvailabilitySetDistributeTraffic, $PSRule.TargetName) } else { $Assert.Pass() }
    }
}

#endregion Availability Set

#region Helper functions

function global:HasPublisherMicrosoftSQLServer {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        $Assert.HasFieldValue($TargetObject, 'properties.storageProfile.imageReference.publisher', 'MicrosoftSQLServer').Result
    }
}

function global:GetOSAndDataDisks {
    [CmdletBinding()]
    [OutputType([PSObject[]])]
    param ()
    process {
        $allowedSkuTypes = @('UltraSSD_LRS', 'PremiumV2_LRS', 'Premium_ZRS', 'Premium_LRS')
        $TargetObject.properties.storageProfile.osDisk.managedDisk |
        Where-Object { $_.storageAccountType -and $_.storageAccountType -notin $allowedSkuTypes }
        $TargetObject.properties.storageProfile.dataDisks |
        Where-Object { $_.managedDisk.storageAccountType -and $_.managedDisk.storageAccountType -notin $allowedSkuTypes }
    }
}

#endregion Helper functions
