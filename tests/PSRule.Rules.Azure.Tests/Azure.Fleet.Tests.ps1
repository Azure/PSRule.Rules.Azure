# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Fleet rules
#

[CmdletBinding()]
param (

)

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

Describe 'Azure.Fleet' -Tag 'Fleet' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Fleet.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.Fleet.PublicKey' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Fleet.PublicKey' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'fleet-002', 'fleet-003';

            $ruleResult[0].Reason | Should -BeExactly "The Azure Fleet 'fleet-002' should have password authentication disabled.";
            $ruleResult[1].Reason | Should -BeExactly "The Azure Fleet 'fleet-003' should have password authentication disabled.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'fleet-001';
        }
    }
}
