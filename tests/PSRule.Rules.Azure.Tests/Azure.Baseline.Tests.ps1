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
            $filteredResult.Length | Should -Be 148;
        }

        It 'With Azure.GA_2020_12' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2020_12' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 169;
        }

        It 'With Azure.GA_2021_03' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2021_03' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 183;
        }

        It 'With Azure.GA_2021_06' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2021_06' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 197;
        }

        It 'With Azure.GA_2021_09' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2021_09' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 215;
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
            $filteredResult.Length | Should -Be 240;
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
            $filteredResult.Length | Should -Be 256;
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
            $filteredResult.Length | Should -Be 260;
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
            $filteredResult.Length | Should -Be 291;
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
            $filteredResult.Length | Should -Be 327;
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
            $filteredResult.Length | Should -Be 347;
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
            $filteredResult.Length | Should -Be 362;
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
            $filteredResult.Length | Should -Be 373;
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
            $filteredResult.Length | Should -Be 382;
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
            $filteredResult.Length | Should -Be 392;
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
            $filteredResult.Length | Should -Be 412;
        }

        It 'With Azure.Preview_2024_06' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2024_06' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 8;
        }

        It 'With Azure.GA_2024_09' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2024_09' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 429;
        }

        It 'With Azure.Preview_2024_09' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2024_09' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 9;
        }

        It 'With Azure.GA_2024_12' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2024_12' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 432;
        }

        It 'With Azure.Preview_2024_12' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2024_12' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 9;
        }

        It 'With Azure.GA_2025_03' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2025_03' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'GA'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 439;
        }

        It 'With Azure.Preview_2025_03' {
            $result = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.Preview_2025_03' -WarningAction Ignore);
            $filteredResult = @($result | Where-Object { $_.Tag.release -in 'preview'});
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Length | Should -Be 9;
        }
    }
}
