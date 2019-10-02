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

Describe 'Azure.VirtualMachine' {
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.VirtualMachine.json';

    Context 'Conditions' {
        $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $dataPath -Outcome All -WarningAction Ignore -ErrorAction Stop;

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
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'vm-A', 'aks-agentpool-00000000-1', 'aks-agentpool-00000000-2', 'aks-agentpool-00000000-3', 'vm-C';
        }

        It 'Azure.VM.Standalone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.Standalone' };

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
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'aks-agentpool-00000000-1', 'aks-agentpool-00000000-2', 'aks-agentpool-00000000-3', 'vm-C';
        }

        It 'Azure.VM.UniqueDns' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.UniqueDns' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'nic-A';

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
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vm-B', 'vm-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vm-A';
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
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'vm-A', 'aks-agentpool-00000000-1', 'aks-agentpool-00000000-2', 'aks-agentpool-00000000-3';
        }

        It 'Azure.VM.Updates' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.Updates' };

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
    }
}
