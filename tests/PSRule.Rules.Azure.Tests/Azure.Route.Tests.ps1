# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Route table rules
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

Describe 'Azure.Route' -Tag 'Network', 'Route' {
    Context 'Resource name' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{ 'AZURE_ROUTE_TABLE_NAME_FORMAT' = '^rt-' };

            $names = @(
                'rt-001'
                'rt-001_'
                'RT.001'
                'r'
                '_rt-001'
                '-rt-001'
                'rt-001-'
                'rt-001.'
                'RT-001'
            )

            $items = @($names | ForEach-Object {
                [PSCustomObject]@{
                    Name         = $_
                    Type = 'Microsoft.Network/routeTables'
                }
            })

            $result = $items | Invoke-PSRule @invokeParams -Option $option -Name 'Azure.Route.Name','Azure.Route.Naming'
        }

        It 'Azure.Route.Name' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Route.Name' };
            $validNames = @(
                'rt-001'
                'rt-001_'
                'RT.001'
                'r'
                'RT-001'
            )

            $invalidNames = @(
                '_rt-001'
                '-rt-001'
                'rt-001-'
                'rt-001.'
            )

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn $invalidNames;
            $ruleResult | Should -HaveCount $invalidNames.Length;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn $validNames;
            $ruleResult | Should -HaveCount $validNames.Length;
        }

        It 'Azure.Route.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Route.Naming' };
            $validNames = @(
                'rt-001'
                'rt-001_'
                'rt-001-'
                'rt-001.'
            )

            $invalidNames = @(
                'RT.001'
                'r'
                '_rt-001'
                '-rt-001'
                'RT-001'
            )

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn $invalidNames;
            $ruleResult | Should -HaveCount $invalidNames.Length;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn $validNames;
            $ruleResult | Should -HaveCount $validNames.Length;
        }
    }
}
