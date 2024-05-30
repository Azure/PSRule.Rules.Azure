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

Describe 'Azure.LogAnalytics' -Tag 'LogAnalytics' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.LogAnalytics.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.LogAnalytics.Replication' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.LogAnalytics.Replication' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'workspace-a', 'workspace-b', 'workspace-c';

            $ruleResult[0].Reason | Should -Be "Path properties.replication.enabled: The field 'properties.replication.enabled' does not exist.";
            $ruleResult[1].Reason | Should -Be "Path properties.replication.enabled: Is set to 'False'.";
            $ruleResult[2].Reason | Should -Be "Path properties.replication.location: The field 'properties.replication.location' does not exist.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'workspace-d';
        }
    }
}
