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

            $ruleResult[0].Reason | Should -BeExactly "Path properties.storageProfile.geoRedundantBackup: Is set to 'Disabled'.";
            $ruleResult[1].Reason | Should -BeExactly "Path properties.storageProfile.geoRedundantBackup: The field 'properties.storageProfile.geoRedundantBackup' does not exist.";

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

        It 'Azure.MariaDB.MinTLS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MariaDB.MinTLS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-B';

            $ruleResult[0].Reason | Should -BeExactly "Path properties.minimalTlsVersion: Is set to 'TLS1_0'.";
            $ruleResult[1].Reason | Should -BeExactly "Path properties.minimalTlsVersion: Does not exist.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'server-C';
        }

        It 'Azure.MariaDB.AllowAzureAccess' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MariaDB.AllowAzureAccess' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-B', 'rule-A';

            $ruleResult[0].Reason | Should -BeExactly "The Azure Database for MariaDB should not allow access to Azure services unless explicitly needed.";
            $ruleResult[1].Reason | Should -BeExactly "The Azure Database for MariaDB should not allow access to Azure services unless explicitly needed.";
            $ruleResult[2].Reason | Should -BeExactly "The Azure Database for MariaDB should not allow access to Azure services unless explicitly needed.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-C', 'server-D/rule-B';
        }

        It 'Azure.MariaDB.FirewallRuleCount' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MariaDB.FirewallRuleCount' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'server-A';

            $ruleResult[0].Reason | Should -BeExactly "The number of firewall rules (11) exceeded 10.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-B', 'server-C';
        }

        It 'Azure.MariaDB.FirewallIPRange' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MariaDB.FirewallIPRange' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'server-A';

            $ruleResult[0].Reason | Should -BeExactly "The number of public IP addresses permitted (255) exceeded 10.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-B', 'server-C';
        }
    }

    Context 'Resource name - Azure.MariaDB.ServerName' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.DBforMariaDB/servers'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'mariadbserver1'
                'mariadbserver-1'
                'mariadbserver'
            )

            $invalidNames = @(
                '-mariadbserver1'
                'mariadbserver1-'
                'mariadbserver.1'
                'mariadbserver_1'
                'MARIADBServer1'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.MariaDB.ServerName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.MariaDB.ServerName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'Resource name - Azure.MariaDB.DatabaseName' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.DBforMariaDB/servers/databases'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'mariadbdatabase1'
                'MARIADBDATABASE1'
                'mariadb-DATABASE1'
                'MARIADB-DATABASE1'
                'server1/MARIADB-DATABASE1'
            )

            $invalidNames = @(
                '_mariadbdatabase1'
                'mariadbdatabase1_'
                'mariadbdatabase.1'
                'MARIA.DB.DATABASE.1'
                'server/MARIA.DB.DATABASE.1'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.MariaDB.DatabaseName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.MariaDB.DatabaseName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'Resource name - Azure.MariaDB.FirewallRuleName' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.DBforMariaDB/servers/firewallRules'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'rule1'
                'server1/default'
                'allowed-developer'
                'blocked-all'
                'BLOCKED-ALL'
            )

            $invalidNames = @(
                'rule.1'
                'allowed.developer'
                'blocked.all'
                'BLOCKED.ALL'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.MariaDB.FirewallRuleName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.MariaDB.FirewallRuleName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'Resource name - Azure.MariaDB.VNETRuleName' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.DBforMariaDB/servers/virtualNetworkRules'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'AllowSubnet'
                'Out-Default'
                'server1/IN-DEFAULT'
                'AllowPeeredSubnet'
            )

            $invalidNames = @(
                'Allow_Subnet'
                'Allow.Subnet'
                'OUT_DEFAULT'
                'Allow_All'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.MariaDB.VNETRuleName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.MariaDB.VNETRuleName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }
}
