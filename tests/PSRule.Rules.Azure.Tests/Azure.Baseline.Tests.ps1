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
            $filteredResult.Length | Should -BeGreaterOrEqual 311;
        }

        It 'With Azure.GA_2020_06' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2020_06' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 135;
        }

        It 'With Azure.GA_2020_09' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2020_09' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 149;
        }

        It 'With Azure.GA_2020_12' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2020_12' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 171;
        }

        It 'With Azure.GA_2021_03' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2021_03' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 185;
        }

        It 'With Azure.GA_2021_06' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2021_06' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 199;
        }

        It 'With Azure.GA_2021_09' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2021_09' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 217;
        }

        It 'With Azure.Preview_2021_09' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2021_09' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 2;
        }

        It 'With Azure.GA_2021_12' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2021_12' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 242;
        }

        It 'With Azure.Preview_2021_12' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2021_12' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 2;
        }

        It 'With Azure.GA_2022_03' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2022_03' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 258;
        }

        It 'With Azure.Preview_2022_03' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2022_03' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 2;
        }

        It 'With Azure.GA_2022_06' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2022_06' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 262;
        }

        It 'With Azure.Preview_2022_06' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2022_06' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 2;
        }

        It 'With Azure.GA_2022_09' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2022_09' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 293;
        }

        It 'With Azure.Preview_2022_09' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2022_09' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 3;
        }

        It 'With Azure.GA_2022_12' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2022_12' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 329;
        }

        It 'With Azure.Preview_2022_12' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2022_12' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 3;
        }

        It 'With Azure.GA_2023_03' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2023_03' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 349;
        }

        It 'With Azure.Preview_2023_03' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2023_03' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 3;
        }

        It 'With Azure.GA_2023_06' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2023_06' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 364;
        }

        It 'With Azure.Preview_2023_06' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2023_06' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 7;
        }

        It 'With Azure.GA_2023_09' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2023_09' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 375;
        }

        It 'With Azure.Preview_2023_09' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2023_09' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 7;
        }

        It 'With Azure.GA_2023_12' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2023_12' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 384;
        }

        It 'With Azure.Preview_2023_12' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2023_12' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 7;
        }

        It 'With Azure.GA_2024_03' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2024_03' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 394;
        }

        It 'With Azure.Preview_2024_03' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2024_03' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 7;
        }

        It 'With Azure.GA_2024_06' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2024_06' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 415;
        }

        It 'With Azure.Preview_2024_06' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2024_06' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 10;
        }

        It 'With Azure.GA_2024_09' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2024_09' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 432;
        }

        It 'With Azure.Preview_2024_09' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2024_09' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 12;
        }
    }
}
