# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Log Analytics rules
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

Describe 'Azure.Log' -Tag 'LogAnalytics','Log' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
                Option = @{
                    'Configuration.AZURE_RESOURCE_ALLOWED_LOCATIONS' = @('australiaeast', 'Australia South East')
                }
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Log.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.Log.Replication' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Log.Replication' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'workspace-a', 'workspace-b', 'workspace-c';

            $ruleResult[0].Reason | Should -Be "Path properties.replication.enabled: The field 'properties.replication.enabled' does not exist.";
            $ruleResult[1].Reason | Should -Be "Path properties.replication.enabled: Is set to 'False'.";
            $ruleResult[2].Reason | Should -Be "Path properties.replication.location: The field 'properties.replication.location' does not exist.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'workspace-d';
        }

        It 'Azure.Log.ReplicaLocation' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Log.ReplicaLocation' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.TargetName | Should -BeIn 'workspace-d';
            $ruleResult.Length | Should -Be 1;

            $ruleResult[0].Reason | Should -Be "Path properties.replication.location: The location 'northeurope' is not in the allowed set of resource locations.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.TargetName | Should -BeIn 'workspace-b';
            $ruleResult.Length | Should -Be 1;
        }
    }

    Context 'Resource name' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{ 'AZURE_LOG_WORKSPACE_NAME_FORMAT' = '^log-' };

            $names = @(
                'log-1'
                'log1'
                'log_1'
                'log.1'
                'log-1-'
                '-log-1'
            )

            $items = @($names | ForEach-Object {
                [PSCustomObject]@{
                    Name         = $_
                    Type = 'Microsoft.OperationalInsights/workspaces'
                }
            })

            $result = $items | Invoke-PSRule @invokeParams -Option $option -Name 'Azure.Log.Name','Azure.Log.Naming'
        }

        It 'Azure.Log.Name' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Log.Name' };
            $validNames = @(
                'log-1'
                'log1'
            )

            $invalidNames = @(
                'log_1'
                'log.1'
                'log-1-'
                '-log-1'
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

        It 'Azure.Log.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Log.Naming' };
            $validNames = @(
                'log-1'
                'log-1-'
            )

            $invalidNames = @(
                'log1'
                'log_1'
                'log.1'
                '-log-1'
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
