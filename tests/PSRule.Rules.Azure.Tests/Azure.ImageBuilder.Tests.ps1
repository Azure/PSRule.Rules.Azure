# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for User Assigned Managed Identity rules
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

Describe 'Azure.ImageBuilder' -Tag 'AIB', 'ImageBuilder', 'ImageTemplate' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.ImageBuilder.Source.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.ImageBuilder.CustomizeHash' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ImageBuilder.CustomizeHash' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'image-001-0';
            $ruleResult.Length | Should -Be 1;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'image-002-0', 'image-003-0';
            $ruleResult.Length | Should -Be 2;
        }

        It 'Azure.ImageBuilder.ValidateHash' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ImageBuilder.ValidateHash' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'image-001-0';
            $ruleResult.Length | Should -Be 1;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'image-002-0', 'image-003-0';
            $ruleResult.Length | Should -Be 2;
        }
    }
}
