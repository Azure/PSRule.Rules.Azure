# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Virtual Machine rules
#

[CmdletBinding()]
param (

)

# Setup error handling
$ErrorActionPreference = 'Stop';
Set-StrictMode -Version latest;

if ($Env:SYSTEM_DEBUG -eq 'true') {
    $VerbosePreference = 'Continue';
}

# Setup tests paths
$rootPath = $PWD;
Import-Module (Join-Path -Path $rootPath -ChildPath out/modules/PSRule.Rules.Azure) -Force;
$here = (Resolve-Path $PSScriptRoot).Path;

Describe 'Azure.VM' {
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.VirtualMachine.json';

    Context 'Conditions' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;

        It 'Azure.VM.UseManagedDisks' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.UseManagedDisks' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vm-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'vm-A', 'aks-agentpool-00000000-1', 'aks-agentpool-00000000-2', 'aks-agentpool-00000000-3', 'vm-C', 'vm-D';
        }

        It 'Azure.VM.Standalone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.Standalone' };

            # Skip Windows client
            $ruleResult = @($filteredResult | Where-Object {
                $_.Outcome -eq 'None' -and $_.TargetName -in 'vm-D'
            });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'vm-A', 'vm-B', 'vm-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'aks-agentpool-00000000-1', 'aks-agentpool-00000000-2', 'aks-agentpool-00000000-3';
        }

        It 'Azure.VM.PromoSku' {
            $expiredSku = @(
                'Standard_DS2_v2_Promo'
                'Standard_DS3_v2_Promo'
                'Standard_DS4_v2_Promo'
                'Standard_DS5_v2_Promo'
                'Standard_DS11_v2_Promo'
                'Standard_DS12_v2_Promo'
                'Standard_DS13_v2_Promo'
                'Standard_DS14_v2_Promo'
                'Standard_D2_v2_Promo'
                'Standard_D3_v2_Promo'
                'Standard_D4_v2_Promo'
                'Standard_D5_v2_Promo'
                'Standard_D11_v2_Promo'
                'Standard_D12_v2_Promo'
                'Standard_D13_v2_Promo'
                'Standard_D14_v2_Promo'
            )
            $notExpiredSku = @(
                'Standard_H8_Promo'
                'Standard_H16_Promo'
            )
            $notPromo = @(
                'Standard_D4s_v3'
            )
            $vmObject = [PSCustomObject]@{
                Name = "vm-A"
                ResourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/vm-A"
                ResourceName = "vm-A"
                ResourceType = "Microsoft.Compute/virtualMachines"
                Properties = [PSCustomObject]@{
                    hardwareProfile = [PSCustomObject]@{
                        vmSize = "nn"
                    }
                }
            }
            foreach ($sku in $expiredSku) {
                $vmObject.Properties.hardwareProfile.vmSize = $sku;
                $result = $vmObject | Invoke-PSRule -Name 'Azure.VM.PromoSku' -Module PSRule.Rules.Azure -WarningAction Ignore;
                $result | Should -Not -BeNullOrEmpty;
                $result.IsSuccess() | Should -Be $False;
            }
            foreach ($sku in $notExpiredSku) {
                $vmObject.Properties.hardwareProfile.vmSize = $sku;
                $result = $vmObject | Invoke-PSRule -Name 'Azure.VM.PromoSku' -Module PSRule.Rules.Azure -WarningAction Ignore;
                $result | Should -Not -BeNullOrEmpty;
                $result.IsSuccess() | Should -Be $True;
            }
            foreach ($sku in $notPromo) {
                $vmObject.Properties.hardwareProfile.vmSize = $sku;
                $result = $vmObject | Invoke-PSRule -Name 'Azure.VM.PromoSku' -Module PSRule.Rules.Azure -WarningAction Ignore -Outcome All;
                $result | Should -Not -BeNullOrEmpty;
                $result.Outcome | Should -Be 'None';
            }
        }

        It 'Azure.VM.BasicSku' {
            $basicSku = @(
                'Basic_A0'
                'Basic_A1'
                'Basic_A2'
                'Basic_A3'
                'Basic_A4'
            )
            $otherSku = @(
                'Standard_D4s_v3'
            )
            $vmObject = [PSCustomObject]@{
                Name = "vm-A"
                ResourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/vm-A"
                ResourceName = "vm-A"
                ResourceType = "Microsoft.Compute/virtualMachines"
                Properties = [PSCustomObject]@{
                    hardwareProfile = [PSCustomObject]@{
                        vmSize = "nn"
                    }
                }
            }
            foreach ($sku in $basicSku) {
                $vmObject.Properties.hardwareProfile.vmSize = $sku;
                $result = $vmObject | Invoke-PSRule -Name 'Azure.VM.BasicSku' -Module PSRule.Rules.Azure -WarningAction Ignore;
                $result | Should -Not -BeNullOrEmpty;
                $result.IsSuccess() | Should -Be $False;
            }
            foreach ($sku in $otherSku) {
                $vmObject.Properties.hardwareProfile.vmSize = $sku;
                $result = $vmObject | Invoke-PSRule -Name 'Azure.VM.BasicSku' -Module PSRule.Rules.Azure -WarningAction Ignore;
                $result | Should -Not -BeNullOrEmpty;
                $result.IsSuccess() | Should -Be $True;
            }
        }

        It 'Azure.VM.DiskCaching' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.DiskCaching' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'vm-A', 'vm-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'aks-agentpool-00000000-1', 'aks-agentpool-00000000-2', 'aks-agentpool-00000000-3', 'vm-C', 'vm-D';
        }

        It 'Azure.VM.UniqueDns' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.UniqueDns' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'nic-A', 'nic-B', 'nic-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'aks-agentpool-00000000-nic-1', 'aks-agentpool-00000000-nic-2', 'aks-agentpool-00000000-nic-3';
        }

        It 'Azure.VM.DiskAttached' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.DiskAttached' };

            # Ignore ASR disks
            $ruleResult = @($filteredResult | Where-Object { $_.TargetName -eq 'ReplicaVM_DataDisk_0-ASRReplica' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult[0].Outcome | Should -Be 'None';
            $ruleResult[0].OutcomeReason | Should -Be 'PreconditionFail';

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'disk-B', 'disk-C';
            $ruleResult.Reason | Should -BeLike 'The resource is not associated.';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'disk-A';
        }

        It 'Azure.VM.DiskSizeAlignment' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.DiskSizeAlignment' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'disk-B', 'ReplicaVM_DataDisk_0-ASRReplica', 'disk-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'disk-A';
        }

        It 'Azure.VM.UseHybridUseBenefit' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.UseHybridUseBenefit' };

            # Skip Linux
            $ruleResult = @($filteredResult | Where-Object {
                $_.Outcome -eq 'None' -and $_.TargetName -in 'aks-agentpool-00000000-1', 'aks-agentpool-00000000-2', 'aks-agentpool-00000000-3'
            });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;

            # Skip Windows client
            $ruleResult = @($filteredResult | Where-Object {
                $_.Outcome -eq 'None' -and $_.TargetName -in 'vm-D'
            });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vm-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vm-A';
        }

        It 'Azure.VM.AcceleratedNetworking' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.AcceleratedNetworking' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'vm-B', 'vm-C', 'vm-D';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vm-A';

            # Check which SKUs are excluded
            $anDisabledSku = @(
                'Standard_F2s_v2'
                'Standard_B2ms'
                'Standard_B4ms'
                'Standard_B8ms'
                'Standard_D2_v3'
                'Standard_D1_v2'
                'Standard_NC6s_v3'
                'Standard_NC6'
                'Standard_A1_v2'
                'Standard_A8_v2'
                'Standard_DS13'
                'Standard_NV12'
            )
            $anEnabledSku = @(
                'Standard_D2_v2'
                'Standard_E4s_v3'
                'Standard_E32s_v3'
                'Standard_D8s_v3'
                'Standard_D4_v3'
                'Standard_D64s_v3'
                'Standard_D5_v2'
                'Standard_D16_v3'
                'Standard_DS11_v2'
                'Standard_B12ms'
                'Standard_B16ms'
                'Standard_B20ms'
                'Standard_F4s_v2'
                'Standard_F8s_v2'
                'Standard_F16s_v2'
            )
            $vmObject = [PSCustomObject]@{
                Name = "vm-A"
                ResourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/vm-A"
                ResourceName = "vm-A"
                ResourceType = "Microsoft.Compute/virtualMachines"
                Properties = [PSCustomObject]@{
                    hardwareProfile = [PSCustomObject]@{
                        vmSize = "na"
                    }
                }
                SubscriptionId = '00000000-0000-0000-0000-000000000000'
                Resources = @(
                    [PSCustomObject]@{
                        ResourceType = 'Microsoft.Network/networkInterfaces'
                    }
                )
            }
            foreach ($sku in $anDisabledSku) {
                $vmObject.Name = $sku;
                $vmObject.Properties.hardwareProfile.vmSize = $sku;
                $result = $vmObject | Invoke-PSRule -Name 'Azure.VM.AcceleratedNetworking' @invokeParams -Outcome All;
                $result | Should -Not -BeNullOrEmpty;
                $result.Outcome | Should -Be 'None';
            }

            foreach ($sku in $anEnabledSku) {
                $vmObject.Name = $sku;
                $vmObject.Properties.hardwareProfile.vmSize = $sku;
                $result = $vmObject | Invoke-PSRule -Name 'Azure.VM.AcceleratedNetworking' @invokeParams -Outcome All;
                $result | Should -Not -BeNullOrEmpty;
                $result.Outcome | Should -Be 'Fail';
            }
        }

        It 'Azure.VM.ASAlignment' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.ASAlignment' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'availabilitySet-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'agentpool-availabilitySet-00000000';
        }

        It 'Azure.VM.ASMinMembers' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.ASMinMembers' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'availabilitySet-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'agentpool-availabilitySet-00000000';
        }

        It 'Azure.VM.ADE' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.ADE' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'disk-B', 'disk-C', 'ReplicaVM_DataDisk_0-ASRReplica';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'disk-A';
        }

        It 'Azure.VM.PublicKey' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.PublicKey' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vm-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'aks-agentpool-00000000-1', 'aks-agentpool-00000000-2', 'aks-agentpool-00000000-3';
        }

        It 'Azure.VM.Agent' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.Agent' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vm-C', 'vm-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'vm-A', 'aks-agentpool-00000000-1', 'aks-agentpool-00000000-2', 'aks-agentpool-00000000-3', 'vm-D';
        }

        It 'Azure.VM.Updates' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.Updates' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'vm-B', 'vm-D';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vm-A';
        }

        It 'Azure.VM.NICAttached' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.NICAttached' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nic-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'nic-A', 'nic-B', 'aks-agentpool-00000000-nic-1', 'aks-agentpool-00000000-nic-2', 'aks-agentpool-00000000-nic-3';
        }

        It 'Azure.VM.Name' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.Name' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'vm-A', 'vm-B', 'vm-C', 'aks-agentpool-00000000-1', 'aks-agentpool-00000000-2', 'aks-agentpool-00000000-3', 'vm-D';
        }

        It 'Azure.VM.ComputerName' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.ComputerName' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'vm-A', 'vm-B', 'vm-C', 'aks-agentpool-00000000-1', 'aks-agentpool-00000000-2', 'aks-agentpool-00000000-3', 'vm-D';
        }

        It 'Azure.VM.DiskName' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.DiskName' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'ReplicaVM_DataDisk_0-ASRReplica', 'disk-A', 'disk-B', 'disk-C';
        }
    }

    Context 'Resource name - Azure.VM.Name' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $validNames = @(
            'vm-001'
            'vm-001_'
            'VM.001'
            '000000'
        )
        $invalidNames = @(
            '_vm-001'
            '-vm-001'
            'vm-001-'
            'vm-001.'
        )
        $testObject = [PSCustomObject]@{
            Name = ''
            ResourceType = 'Microsoft.Compute/virtualMachines'
        }

        # Pass
        foreach ($name in $validNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VM.Name';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Pass';
            }
        }

        # Fail
        foreach ($name in $invalidNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VM.Name';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Fail';
            }
        }
    }

    Context 'Resource name - Azure.VM.ComputerName (Windows)' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $validNames = @(
            'vm-001'
            '-vm-001-'
            'v'
            'virtualMachine1'
            'v00000'
        )
        $invalidNames = @(
            'vm_001'
            'vm.001'
            '0000000'
            'virtualMachine01'
        )
        $testObject = [PSCustomObject]@{
            ResourceType = 'Microsoft.Compute/virtualMachines'
            Properties = [PSCustomObject]@{
                storageProfile = [PSCustomObject]@{
                    osDisk = [PSCustomObject]@{
                        osType = 'Windows'
                    }
                }
                osProfile = [PSCustomObject]@{
                    computerName = ''
                }
            }
        }

        # Pass
        foreach ($name in $validNames) {
            It $name {
                $testObject.Properties.osProfile.computerName = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VM.ComputerName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Pass';
            }
        }

        # Fail
        foreach ($name in $invalidNames) {
            It $name {
                $testObject.Properties.osProfile.computerName = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VM.ComputerName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Fail';
            }
        }
    }

    Context 'Resource name - Azure.VM.ComputerName (Linux)' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $validNames = @(
            'vm-001'
            'VM.001'
            '000000'
            'vm-001-'
            'vm-001.'
            'v'
            'virtualMachine01'
        )
        $invalidNames = @(
            'vm_001'
            '-vm-001'
        )
        $testObject = [PSCustomObject]@{
            ResourceType = 'Microsoft.Compute/virtualMachines'
            Properties = [PSCustomObject]@{
                storageProfile = [PSCustomObject]@{
                    osDisk = [PSCustomObject]@{
                        osType = 'Linux'
                    }
                }
                osProfile = [PSCustomObject]@{
                    computerName = ''
                }
            }
        }

        # Pass
        foreach ($name in $validNames) {
            It $name {
                $testObject.Properties.osProfile.computerName = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VM.ComputerName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Pass';
            }
        }

        # Fail
        foreach ($name in $invalidNames) {
            It $name {
                $testObject.Properties.osProfile.computerName = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VM.ComputerName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Fail';
            }
        }
    }

    Context 'Resource name - Azure.VM.DiskName' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $validNames = @(
            'disk-001'
            'disk-001_'
            'DISK.001'
            'd'
        )
        $invalidNames = @(
            '_disk-001'
            '-disk-001'
            '.disk-001'
            'disk-001-'
            'disk-001.'
        )
        $testObject = [PSCustomObject]@{
            Name = ''
            ResourceType = 'Microsoft.Compute/disks'
        }

        # Pass
        foreach ($name in $validNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VM.DiskName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Pass';
            }
        }

        # Fail
        foreach ($name in $invalidNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VM.DiskName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Fail';
            }
        }
    }

    Context 'Resource name - Azure.VM.ASName' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $validNames = @(
            'as-001'
            'as-001_'
            'AS.001'
            'a'
        )
        $invalidNames = @(
            '_as-001'
            '-as-001'
            '.as-001'
            'as-001-'
            'as-001.'
        )
        $testObject = [PSCustomObject]@{
            Name = ''
            ResourceType = 'Microsoft.Compute/availabilitySets'
        }

        # Pass
        foreach ($name in $validNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VM.ASName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Pass';
            }
        }

        # Fail
        foreach ($name in $invalidNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VM.ASName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Fail';
            }
        }
    }

    Context 'Resource name - Azure.VM.NICName' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $validNames = @(
            'nic-001'
            'nic-001_'
            'NIC.001'
            'n'
        )
        $invalidNames = @(
            '_nic-001'
            '-nic-001'
            '.nic-001'
            'nic-001-'
            'nic-001.'
        )
        $testObject = [PSCustomObject]@{
            Name = ''
            ResourceType = 'Microsoft.Network/networkInterfaces'
        }

        # Pass
        foreach ($name in $validNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VM.NICName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Pass';
            }
        }

        # Fail
        foreach ($name in $invalidNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VM.NICName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Fail';
            }
        }
    }

    Context 'Resource name - Azure.VM.PPGName' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $validNames = @(
            'ppg_001'
            'ppg-001'
            'PPG.001'
            'p'
        )
        $invalidNames = @(
            '_ppg-001'
            '-ppg-001'
            '.ppg-001'
            'ppg-001_'
            'ppg-001-'
            'ppg-001.'
        )
        $testObject = [PSCustomObject]@{
            Name = ''
            ResourceType = 'Microsoft.Compute/proximityPlacementGroups'
        }

        # Pass
        foreach ($name in $validNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VM.PPGName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Pass';
            }
        }

        # Fail
        foreach ($name in $invalidNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.VM.PPGName';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Fail';
            }
        }
    }

    Context 'With template' {
        $templatePath = Join-Path -Path $here -ChildPath 'Resources.VirtualMachine.Template.json';
        $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.VirtualMachine.json;
        Export-AzRuleTemplateData -TemplateFile $templatePath -OutputPath $outputFile;
        $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;

        It 'Azure.VM.UseManagedDisks' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.UseManagedDisks' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vm-A';
        }

        It 'Azure.VM.Standalone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.Standalone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vm-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;
        }

        It 'Azure.VM.PromoSku' {
            $expiredSku = @(
                'Standard_DS2_v2_Promo'
                'Standard_DS3_v2_Promo'
                'Standard_DS4_v2_Promo'
                'Standard_DS5_v2_Promo'
                'Standard_DS11_v2_Promo'
                'Standard_DS12_v2_Promo'
                'Standard_DS13_v2_Promo'
                'Standard_DS14_v2_Promo'
                'Standard_D2_v2_Promo'
                'Standard_D3_v2_Promo'
                'Standard_D4_v2_Promo'
                'Standard_D5_v2_Promo'
                'Standard_D11_v2_Promo'
                'Standard_D12_v2_Promo'
                'Standard_D13_v2_Promo'
                'Standard_D14_v2_Promo'
            )
            $notExpiredSku = @(
                'Standard_H8_Promo'
                'Standard_H16_Promo'
            )
            $notPromo = @(
                'Standard_D4s_v3'
            )
            $vmObject = [PSCustomObject]@{
                Name = "vm-A"
                ResourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/vm-A"
                ResourceName = "vm-A"
                ResourceType = "Microsoft.Compute/virtualMachines"
                Properties = [PSCustomObject]@{
                    hardwareProfile = [PSCustomObject]@{
                        vmSize = "nn"
                    }
                }
            }
            foreach ($sku in $expiredSku) {
                $vmObject.Properties.hardwareProfile.vmSize = $sku;
                $result = $vmObject | Invoke-PSRule -Name 'Azure.VM.PromoSku' -Module PSRule.Rules.Azure -WarningAction Ignore;
                $result | Should -Not -BeNullOrEmpty;
                $result.IsSuccess() | Should -Be $False;
            }
            foreach ($sku in $notExpiredSku) {
                $vmObject.Properties.hardwareProfile.vmSize = $sku;
                $result = $vmObject | Invoke-PSRule -Name 'Azure.VM.PromoSku' -Module PSRule.Rules.Azure -WarningAction Ignore;
                $result | Should -Not -BeNullOrEmpty;
                $result.IsSuccess() | Should -Be $True;
            }
            foreach ($sku in $notPromo) {
                $vmObject.Properties.hardwareProfile.vmSize = $sku;
                $result = $vmObject | Invoke-PSRule -Name 'Azure.VM.PromoSku' -Module PSRule.Rules.Azure -WarningAction Ignore -Outcome All;
                $result | Should -Not -BeNullOrEmpty;
                $result.Outcome | Should -Be 'None';
            }
        }

        It 'Azure.VM.BasicSku' {
            $basicSku = @(
                'Basic_A0'
                'Basic_A1'
                'Basic_A2'
                'Basic_A3'
                'Basic_A4'
            )
            $otherSku = @(
                'Standard_D4s_v3'
            )
            $vmObject = [PSCustomObject]@{
                Name = "vm-A"
                ResourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Compute/virtualMachines/vm-A"
                ResourceName = "vm-A"
                ResourceType = "Microsoft.Compute/virtualMachines"
                Properties = [PSCustomObject]@{
                    hardwareProfile = [PSCustomObject]@{
                        vmSize = "nn"
                    }
                }
            }
            foreach ($sku in $basicSku) {
                $vmObject.Properties.hardwareProfile.vmSize = $sku;
                $result = $vmObject | Invoke-PSRule -Name 'Azure.VM.BasicSku' -Module PSRule.Rules.Azure -WarningAction Ignore;
                $result | Should -Not -BeNullOrEmpty;
                $result.IsSuccess() | Should -Be $False;
            }
            foreach ($sku in $otherSku) {
                $vmObject.Properties.hardwareProfile.vmSize = $sku;
                $result = $vmObject | Invoke-PSRule -Name 'Azure.VM.BasicSku' -Module PSRule.Rules.Azure -WarningAction Ignore;
                $result | Should -Not -BeNullOrEmpty;
                $result.IsSuccess() | Should -Be $True;
            }
        }

        It 'Azure.VM.DiskCaching' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.DiskCaching' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vm-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;
        }

        It 'Azure.VM.UniqueDns' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.UniqueDns' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'vm-A-nic1';
        }

        It 'Azure.VM.DiskAttached' {
            $filteredResult = $result | Where-Object {
                $_.RuleName -eq 'Azure.VM.DiskAttached' -and
                $_.TargetType -eq 'Microsoft.Compute/disks'
            };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vm-A-disk1', 'vm-A-disk2';
        }

        It 'Azure.VM.DiskSizeAlignment' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.DiskSizeAlignment' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vm-A-disk1', 'vm-A-disk2';
        }

        It 'Azure.VM.UseHybridUseBenefit' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.UseHybridUseBenefit' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vm-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;
        }

        It 'Azure.VM.AcceleratedNetworking' {
            $filteredResult = $result | Where-Object {
                $_.RuleName -eq 'Azure.VM.AcceleratedNetworking' -and
                $_.TargetType -eq 'Microsoft.Compute/virtualMachines'
            };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vm-A';
        }

        It 'Azure.VM.ADE' {
            $filteredResult = $result | Where-Object {
                $_.RuleName -eq 'Azure.VM.ADE' -and
                $_.TargetType -eq 'Microsoft.Compute/disks'
            };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vm-A-disk1', 'vm-A-disk2';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;
        }

        It 'Azure.VM.PublicKey' {
            $filteredResult = $result | Where-Object {
                $_.RuleName -eq 'Azure.VM.PublicKey' -and
                $_.TargetType -eq 'Microsoft.Compute/virtualMachines'
            };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'vm-A';
        }

        It 'Azure.VM.Agent' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.Agent' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'vm-A';
        }

        It 'Azure.VM.Updates' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.Updates' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vm-A';
        }

        It 'Azure.VM.NICAttached' {
            $filteredResult = $result | Where-Object {
                $_.RuleName -eq 'Azure.VM.NICAttached' -and
                $_.TargetType -eq 'Microsoft.Network/networkInterfaces'
            };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'vm-A-nic1';
        }
    }
}
