# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure Virtual Machines
#

# Synopsis: Virtual machines should use managed disks
Rule 'Azure.VM.UseManagedDisks' -Type 'Microsoft.Compute/virtualMachines' -Tag @{ release = 'GA' } {
    # Check OS disk
    $Null -ne $TargetObject.properties.storageProfile.osDisk.managedDisk.id

    # Check data disks
    if ($TargetObject.properties.storageProfile.dataDisks.Count -gt 0) {
        $count = ($TargetObject.properties.storageProfile.dataDisks.managedDisk.id | Measure-Object).Count
        $count -eq $TargetObject.properties.storageProfile.dataDisks.Count
    }
}

# Synopsis: VMs must use premium disks or use availability sets/ zones to meet SLA requirements
Rule 'Azure.VM.Standalone' -Type 'Microsoft.Compute/virtualMachines' -Tag @{ release = 'GA' } {
    $types = @(
        $TargetObject.properties.storageProfile.osDisk.managedDisk.storageAccountType
        $TargetObject.properties.storageProfile.dataDisks.managedDisk.storageAccountType
    )

    $premiumCount = $types | Where-Object { $_ -eq 'Premium_LRS' };

    AnyOf {
        # A member of an availability set
        $Null -ne $TargetObject.properties.availabilitySet.id

        $premiumCount -eq (($TargetObject.properties.storageProfile.dataDisks | Measure-Object).Count + 1)
    }
}

# Synopsis: VMs should not use expired promo SKU
Rule 'Azure.VM.PromoSku' -If { (IsVMPromoSku) } -Tag @{ release = 'GA' } {
    Match 'Properties.hardwareProfile.vmSize' -Not -Expression 'Standard_DS{0,1}1{0,1}[1-9]{1}_v2_Promo'
}

# Synopsis: VMs should not use Basic SKU
Rule 'Azure.VM.BasicSku' -Type 'Microsoft.Compute/virtualMachines' -Tag @{ release = 'GA' } {
    Match 'Properties.hardwareProfile.vmSize' -Not -Expression 'Basic_A[0-4]'
}

# Synopsis: Check disk caching is configured correctly for the workload
Rule 'Azure.VM.DiskCaching' -Type 'Microsoft.Compute/virtualMachines' -Tag @{ release = 'GA' } {
    # Check OS disk
    Within 'properties.storageProfile.osDisk.caching' 'ReadWrite'

    # Check data disks
    $dataDisks = @($TargetObject.properties.storageProfile.dataDisks)

    foreach ($disk in $dataDisks) {
        if ($disk.managedDisk.storageAccountType -eq 'Premium_LRS') {
            $disk.caching -eq 'ReadOnly'
        }
        else {
            $disk.caching -eq 'None'
        }
    }
}

# Synopsis: Network interfaces should inherit from virtual network
Rule 'Azure.VM.UniqueDns' -Type 'Microsoft.Network/networkInterfaces' -Tag @{ release = 'GA' } {
    $Assert.NullOrEmpty($TargetObject, 'Properties.dnsSettings.dnsServers')
}

# Synopsis: Managed disks should be attached to virtual machines
Rule 'Azure.VM.DiskAttached' -Type 'Microsoft.Compute/disks' -If { ($TargetObject.ResourceName -notlike '*-ASRReplica') } -Tag @{ release = 'GA' } {
    # Disks should be attached unless they are used by ASR, which are not attached until fail over
    # Disks for VMs that are off are marked as Reserved
    Within 'properties.diskState' 'Attached', 'Reserved' -Reason $LocalizedData.ResourceNotAssociated
}

# TODO: Check IOPS

# Synopsis: Managed disk is smaller than SKU size
Rule 'Azure.VM.DiskSizeAlignment' -Type 'Microsoft.Compute/disks' -Tag @{ release = 'GA' } {
    $diskSize = @(32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768)
    $actualSize = $TargetObject.properties.diskSizeGB

    # Find the closest disk size
    $i = 0;
    while ($actualSize -gt $diskSize[$i]) {
        $i++;
    }

    # Actual disk size should be the disk size within 5GB
    $actualSize -ge ($diskSize[$i] - 5);
}

# TODO: Check number of disks

# Synopsis: Use Hybrid Use Benefit
Rule 'Azure.VM.UseHybridUseBenefit' -If { (IsWindowsOS) } -Tag @{ release = 'GA' } {
    Within 'properties.licenseType' 'Windows_Server'
}

# Synopsis: Enabled accelerated networking for supported operating systems
Rule 'Azure.VM.AcceleratedNetworking' -If { (SupportsAcceleratedNetworking) } -Tag @{ release = 'GA' } {
    $networkInterfaces = GetSubResources -ResourceType 'Microsoft.Network/networkInterfaces'
    foreach ($interface in $networkInterfaces) {
        ($interface.Properties.enableAcceleratedNetworking -eq $True)
    }
}

# Synopsis: Availability sets should be aligned
Rule 'Azure.VM.ASAlignment' -Type 'Microsoft.Compute/availabilitySets' -Tag @{ release = 'GA' } {
    Within 'sku.name' 'aligned'
}

# Synopsis: Availability sets should be deployed with at least two members
Rule 'Azure.VM.ASMinMembers' -Type 'Microsoft.Compute/availabilitySets' -Tag @{ release = 'GA' } {
    ($TargetObject.properties.virtualmachines.id | Measure-Object).Count -ge 2
}

# Synopsis: Use Azure Disk Encryption
Rule 'Azure.VM.ADE' -Type 'Microsoft.Compute/disks' -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.encryptionSettingsCollection.enabled', $True)
    $Assert.HasFieldValue($TargetObject, 'Properties.encryptionSettingsCollection.encryptionSettings')
}

# Synopsis: Linux VMs should use public key pair
Rule 'Azure.VM.PublicKey' -If { (IsLinuxOS) } -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.osProfile.linuxConfiguration.disablePasswordAuthentication', $True)
}

# Synopsis: Ensure that the VM agent is provisioned automatically
Rule 'Azure.VM.Agent' -Type 'Microsoft.Compute/virtualMachines' -Tag @{ release = 'GA' } {
    $Assert.HasDefaultValue($TargetObject, 'Properties.osProfile.linuxConfiguration.provisionVMAgent', $True)
    $Assert.HasDefaultValue($TargetObject, 'Properties.osProfile.windowsConfiguration.provisionVMAgent', $True)
}

# Synopsis: Ensure automatic updates are enabled at deployment
Rule 'Azure.VM.Updates' -Type 'Microsoft.Compute/virtualMachines' -If { (IsWindowsOS) } -Tag @{ release = 'GA' } {
    $Assert.HasDefaultValue($TargetObject, 'Properties.osProfile.windowsConfiguration.enableAutomaticUpdates', $True)
}

#region Network Interface

# Synopsis: Network interfaces should be attached
Rule 'Azure.VM.NICAttached' -Type 'Microsoft.Network/networkInterfaces' -Tag @{ release = 'GA' } {
    Exists 'Properties.virtualMachine.id'
}

#endregion Network Interface
