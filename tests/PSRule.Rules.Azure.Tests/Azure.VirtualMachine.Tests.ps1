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
}$ErrorActionPreference = 'Stop';
Set-StrictMode -Version latest;

# Setup tests paths
$rootPath = $PWD;
Import-Module (Join-Path -Path $rootPath -ChildPath out/modules/PSRule.Rules.Azure) -Force;
$here = (Resolve-Path $PSScriptRoot).Path;

Describe 'Azure.VirtualMachine' {
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.VirtualMachine.json';

    Context 'Conditions' {
        $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $dataPath -Outcome All -WarningAction Ignore;

        It 'Azure.VirtualMachine.UseManagedDisks' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualMachine.UseManagedDisks' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'vm-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'vm-A', 'aks-agentpool-00000000-1', 'aks-agentpool-00000000-2', 'aks-agentpool-00000000-3';
        }

        It 'Azure.VirtualMachine.Standalone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualMachine.Standalone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'vm-A', 'vm-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'aks-agentpool-00000000-1', 'aks-agentpool-00000000-2', 'aks-agentpool-00000000-3';
        }

        It 'Azure.VirtualMachine.DiskCaching' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualMachine.DiskCaching' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'vm-A', 'vm-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'aks-agentpool-00000000-1', 'aks-agentpool-00000000-2', 'aks-agentpool-00000000-3';
        }

        It 'Azure.VirtualMachine.UniqueDns' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualMachine.UniqueDns' };

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

        It 'Azure.VirtualMachine.DiskAttached' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualMachine.DiskAttached' };

            # Ignore ASR disks
            $ruleResult = @($filteredResult | Where-Object { $_.TargetName -eq 'ReplicaVM_DataDisk_0-ASRReplica' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult[0].Outcome | Should -Be 'None';
            $ruleResult[0].OutcomeReason | Should -Be 'PreconditionFail';

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'disk-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'disk-A';
        }

        It 'Azure.VirtualMachine.DiskSizeAlignment' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualMachine.DiskSizeAlignment' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'disk-B', 'ReplicaVM_DataDisk_0-ASRReplica';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'disk-A';
        }

        It 'Azure.VirtualMachine.UseHybridUseBenefit' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualMachine.UseHybridUseBenefit' };

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

        It 'Azure.VirtualMachine.AcceleratedNetworking' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualMachine.AcceleratedNetworking' };

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

        It 'Azure.VirtualMachine.ASAlignment' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualMachine.ASAlignment' };

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

        It 'Azure.VirtualMachine.ASMinMembers' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VirtualMachine.ASMinMembers' };

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
    }
}
