# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Database for MySQL rules
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

Describe 'Azure.MySQL' -Tag 'MySql' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.MySQL.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.MySQL.UseSSL' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MySQL.UseSSL' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'server-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'server-A', 'server-C';
        }

        It 'Azure.MySQL.MinTLS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MySQL.MinTLS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-B', 'server-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'server-A';
        }

        It 'Azure.MySQL.FirewallRuleCount' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MySQL.FirewallRuleCount' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'server-B';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The number of firewall rules (11) exceeded 10.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-C';
        }

        It 'Azure.MySQL.AllowAzureAccess' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MySQL.AllowAzureAccess' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'server-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-C';
        }

        It 'Azure.MySQL.FirewallIPRange' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MySQL.FirewallIPRange' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'server-B';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The number of public IP addresses permitted (255) exceeded 10.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-C';
        }

        It 'Azure.MySQL.GeoRedundantBackup' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MySQL.GeoRedundantBackup' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-B', 'server-E', 'server-F';

            $ruleResult[0].Reason | Should -BeExactly "The Azure Database for MySQL 'server-B' should have geo-redundant backup configured.";
            $ruleResult[1].Reason | Should -BeExactly "The Azure Database for MySQL 'server-A' should have geo-redundant backup configured.";
            $ruleResult[2].Reason | Should -BeExactly "The Azure Database for MySQL 'server-E' should have geo-redundant backup configured.";
            $ruleResult[3].Reason | Should -BeExactly "The Azure Database for MySQL 'server-F' should have geo-redundant backup configured.";
           
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-C', 'server-D';
        }

        It 'Azure.MySQL.DefenderCloud' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MySQL.DefenderCloud' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-B', 'server-F/Default';

            $ruleResult[0].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.DBforMySQL/servers/securityAlertPolicies' has not been specified.";
            $ruleResult[1].Reason | Should -BeExactly "Path resources.properties.state: Is set to 'Disabled'.";
            $ruleResult[2].Reason | Should -BeExactly "Path properties.state: Is set to 'Disabled'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-C', 'server-E/Default';
        }

        It 'Azure.MySQL.UseFlexible' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MySQL.UseFlexible' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-B', 'server-C';

            $ruleResult[0].Reason | Should -BeExactly "The Azure Database for MySQL Single Server deployment model is on the retirement path. Migrate to the Azure Database for MySQL Flexible Server deployment model.";
            $ruleResult[1].Reason | Should -BeExactly "The Azure Database for MySQL Single Server deployment model is on the retirement path. Migrate to the Azure Database for MySQL Flexible Server deployment model.";
            $ruleResult[2].Reason | Should -BeExactly "The Azure Database for MySQL Single Server deployment model is on the retirement path. Migrate to the Azure Database for MySQL Flexible Server deployment model.";
        
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'server-D', 'server-E', 'server-F';
        }

        It 'Azure.MySQL.AAD' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MySQL.AAD' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-B', 'server-D', 'server-E', 'ActiveDirectoryAdmin-A', 'ActiveDirectoryAdmin-C';

            $ruleResult[0].Reason | Should -BeIn 'Path properties.administratorType: Is null or empty.', 'Path properties.login: Is null or empty.', 'Path properties.sid: Is null or empty.';
            $ruleResult[1].Reason | Should -BeIn "A sub-resource of type 'Microsoft.DBforMySQL/servers/administrators' has not been specified.";
            $ruleResult[2].Reason | Should -BeIn "A sub-resource of type 'Microsoft.DBforMySQL/flexibleServers/administrators' has not been specified.";
            $ruleResult[3].Reason | Should -BeIn 'Path properties.administratorType: Is null or empty.', 'Path properties.identityResourceId: Is null or empty.', 'Path properties.login: Is null or empty.', 'Path properties.sid: Is null or empty.';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'server-C', 'server-F', 'ActiveDirectoryAdmin-B', 'ActiveDirectoryAdmin-D';
        }

        It 'Azure.MySQL.AADOnly' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MySQL.AADOnly' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'server-D', 'server-E', 'aad_auth_only-A';

            $ruleResult[0].Reason | Should -BeIn "A sub-resource of type 'Microsoft.DBforMySQL/flexibleServers/configurations' has not been specified.";
            $ruleResult[1].Reason | Should -BeIn "Path properties.value: Is set to 'OFF'.";
            $ruleResult[2].Reason | Should -BeIn "Path properties.value: Is set to 'OFF'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-F', 'aad_auth_only-B';
        }
    }

    Context 'Resource name - Azure.MySQL.ServerName' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.DBforMySQL/servers'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'sqlserver1'
                'sqlserver-1'
                '1sqlserver'
            )

            $invalidNames = @(
                '-sqlserver1'
                'sqlserver1-'
                'sqlserver.1'
                'sqlserver_1'
                'SQLServer1'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.MySQL.ServerName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.MySQL.ServerName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }
}
