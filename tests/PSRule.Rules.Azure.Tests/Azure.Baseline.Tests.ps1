# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for baselines
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

Describe 'Baselines' -Tag Baseline {
    Context 'Binding' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Resource.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'TargetType' {
            $result.TargetType | Should -Not -BeIn 'System.Management.Automation.PSCustomObject';
        }
    }

    Context 'Rule' {
        It 'With default baseline' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Default' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -eq 'preview'});
            $filteredResult | Should -BeNullOrEmpty;
        }

        It 'With Azure.Preview' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA', 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -BeGreaterThan 150;
        }

        It 'With Azure.GA_2020_06' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2020_06' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 138;
        }

        It 'With Azure.GA_2020_09' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2020_09' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 154;
        }

        It 'With Azure.GA_2020_12' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2020_12' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 178;
        }

        It 'With Azure.GA_2021_03' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2021_03' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 193;
        }

        It 'With Azure.GA_2021_06' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2021_06' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 207;
        }

        It 'With Azure.GA_2021_09' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2021_09' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 228;
        }
    }
}
