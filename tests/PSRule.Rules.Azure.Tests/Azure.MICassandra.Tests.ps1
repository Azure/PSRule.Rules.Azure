# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Managed Instance for Apache Cassandra rules
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

Describe 'Azure.MICassandra' -Tag 'MICassandra', 'ManagedCassandra' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.MICassandra.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.MICassandra.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MICassandra.AvailabilityZone' };

            # Fail - datacenters without availability zones in supported regions
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'micassandra-b/datacenter-b', 'micassandra-d', 'micassandra-e', 'micassandra-h/datacenter-j';

            # Pass - clusters and datacenters with availability zones, and those in unsupported regions
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'micassandra-a', 'micassandra-a/datacenter-a', 'micassandra-b', 'micassandra-c', 'micassandra-f', 'micassandra-g/datacenter-i', 'micassandra-i/datacenter-k';
        }
    }
}
