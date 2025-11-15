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

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' } | Sort-Object TargetName);
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'micassandra-b', 'micassandra-c', 'micassandra-f/datacenter-a';

            $ruleResult[0].Reason | Should -Be "Path properties.availabilityZone: The Managed Instance for Apache Cassandra data center (datacenter-a) deployed to region (westus2) should should have zone redundancy enabled.";
            $ruleResult[1].Reason | Should -Be "Path properties.availabilityZone: The Managed Instance for Apache Cassandra data center (datacenter-b) deployed to region (eastus) should should have zone redundancy enabled.";
            $ruleResult[2].Reason | Should -Be "Path properties.availabilityZone: The Managed Instance for Apache Cassandra data center (micassandra-f/datacenter-a) deployed to region (westus2) should should have zone redundancy enabled.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'micassandra-a', 'micassandra-d', 'micassandra-e', 'micassandra-f', 'micassandra-e/datacenter-a', 'micassandra-g/datacenter-a';
        }
    }
}
