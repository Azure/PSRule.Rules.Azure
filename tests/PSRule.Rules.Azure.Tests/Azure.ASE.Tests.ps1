# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure App Service Environment rules
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

Describe 'Azure.ASE' -Tag 'ASE' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.ASE.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.ASE.MigrateV3' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ASE.MigrateV3' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'environment-A', 'environment-B', 'environment-D';

            $ruleResult[0].Reason | Should -BeExactly "The app service environment 'environment-A' with version 'ASEV1' is deprecated and will be retired on August 31, 2024. Migrate to ASEv3.";
            $ruleResult[1].Reason | Should -BeExactly "The app service environment 'environment-B' with version 'ASEV2' is deprecated and will be retired on August 31, 2024. Migrate to ASEv3.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'environment-C', 'environment-E', 'environment-F';
        }

        It 'Azure.ASE.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ASE.AvailabilityZone' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'environment-A', 'environment-B', 'environment-D';

            $ruleResult[0].Reason | Should -BeExactly @(
                "The app service environment (environment-A) is not deployed with a version that supports zone-redundancy."
                "The app service environment (environment-A) deployed to region (westeurope) should use three availability zones from the following [1, 2, 3]."
                ):
            $ruleResult[1].Reason | Should -BeExactly @(
                "The app service environment (environment-B) is not deployed with a version that supports zone-redundancy."
                "The app service environment (environment-B) deployed to region (westeurope) should use three availability zones from the following [1, 2, 3]."
                ):
            $ruleResult[2].Reason | Should -BeExactly "The app service environment (environment-D) is not deployed with a version that supports zone-redundancy.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'environment-C', 'environment-E', 'environment-F';
        }
    }
}
