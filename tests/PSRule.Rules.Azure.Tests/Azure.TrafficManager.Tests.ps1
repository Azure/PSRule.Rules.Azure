# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Traffic Manager rules
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

Describe 'Azure.TrafficManager' -Tag 'TrafficManager' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.TrafficManager.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All; 
        }

        It 'Azure.TrafficManager.Endpoints' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.TrafficManager.Endpoints' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'profile-B', 'profile-C';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The number of enabled endpoints is 1.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The number of enabled endpoints is 1.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'profile-A';
        }

        It 'Azure.TrafficManager.Protocol' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.TrafficManager.Protocol' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'profile-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'profile-C';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'profile-B';
        }
    }
}
