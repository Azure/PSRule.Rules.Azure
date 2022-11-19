# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Database for Maria DB rules
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

Describe 'Azure.MariaDB' -Tag 'MariaDB' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.MariaDB.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.MariaDB.GeoRedundantBackup' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MariaDB.GeoRedundantBackup' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-B';

            $ruleResult[0].Reason | Should -BeExactly "The Azure Database for MariaDB 'server-A' should have geo-redundant backup configured.";
            $ruleResult[1].Reason | Should -BeExactly "The Azure Database for MariaDB 'server-B' should have geo-redundant backup configured.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'server-C';
        }

        It 'Azure.MariaDB.DefenderCloud' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MariaDB.DefenderCloud' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-B';

            $ruleResult[0].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.DBforMariaDB/servers/securityAlertPolicies' has not been specified.";
            $ruleResult[1].Reason | Should -BeExactly "Path resources.properties.state: Is set to 'Disabled'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'server-C';
        }
        
        It 'Azure.MariaDB.UseSSL' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MariaDB.UseSSL' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-B';

            $ruleResult[0].Reason | Should -BeExactly "The Azure Database for MariaDB should only accept encrypted connections.";
            $ruleResult[1].Reason | Should -BeExactly "The Azure Database for MariaDB should only accept encrypted connections.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'server-C';
        }
    }
}
