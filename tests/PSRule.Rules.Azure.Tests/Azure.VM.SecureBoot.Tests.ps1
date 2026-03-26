# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure VM and VMSS Secure Boot rules
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

Describe 'Azure.VM.SecureBoot' -Tag 'VM', 'SecureBoot' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
                Option        = (Join-Path -Path $here -ChildPath 'ps-rule-options.yaml')
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.VM.SecureBoot.json'
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.VM.SecureBoot' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VM.SecureBoot' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Contain 'vm-secureBoot-fail-none';
            $ruleResult.TargetName | Should -Contain 'vm-secureBoot-fail-disabled';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Contain 'vm-secureBoot-pass';
            $ruleResult.TargetName | Should -Contain 'vm-secureBoot-confidential';
        }

        It 'Azure.VMSS.SecureBoot' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.VMSS.SecureBoot' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Contain 'vmss-secureBoot-fail-none';
            $ruleResult.TargetName | Should -Contain 'vmss-secureBoot-fail-disabled';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Contain 'vmss-secureBoot-pass';
            $ruleResult.TargetName | Should -Contain 'vmss-secureBoot-confidential';
        }
    }
}
