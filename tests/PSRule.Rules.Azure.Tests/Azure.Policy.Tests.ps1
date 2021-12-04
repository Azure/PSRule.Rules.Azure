# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Policy rules
#

[CmdletBinding()]
param ()

BeforeAll {
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
}

Describe 'Azure.Policy' -Tag Policy {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Policy.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.Policy.Descriptors' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Policy.Descriptors' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'initiative-002', 'initiative-003', 'policy-002', 'policy-003';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'initiative-001', 'policy-001';
        }

        It 'Azure.Policy.AssignmentDescriptors' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Policy.AssignmentDescriptors' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'assignment-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'assignment-002';
        }

        It 'Azure.Policy.AssignmentAssignedBy' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Policy.AssignmentAssignedBy' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'assignment-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'assignment-002';
        }

        It 'Azure.Policy.ExemptionDescriptors' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Policy.ExemptionDescriptors' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'exemption-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'exemption-002', 'exemption-003';
        }

        It 'Azure.Policy.WaiverExpiry' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Policy.WaiverExpiry' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'exemption-001', 'exemption-002';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'exemption-003';
        }
    }

    Context 'With Template' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Resources.Policy.Parameters.json')
                (Join-Path -Path $here -ChildPath 'Resources.Policy.Parameters.2.json')
            )
            $options = @{
                'Configuration.AZURE_PARAMETER_FILE_EXPANSION' = $True
            }
            $result = Invoke-PSRule @invokeParams -Option $options -InputPath $dataPath -Format File -Outcome All;
        }

        It 'Azure.Policy.Descriptors' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Policy.Descriptors' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'standards', 'inheritTagPolicy', 'rgRequireTagPolicy', 'rgApplyTagPolicy';
        }

        It 'Azure.Policy.AssignmentDescriptors' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Policy.AssignmentDescriptors' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'standards-assignment';
        }

        It 'Azure.Policy.AssignmentAssignedBy' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Policy.AssignmentAssignedBy' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'standards-assignment';
        }

        It 'Azure.Policy.WaiverExpiry' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Policy.WaiverExpiry' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'ffffffff-ffff-ffff-ffff-ffffffffffff-test';
        }
    }
}
