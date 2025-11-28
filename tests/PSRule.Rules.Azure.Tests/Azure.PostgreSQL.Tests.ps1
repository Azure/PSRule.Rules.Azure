# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Database for PostgreSQL rules
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

Describe 'Azure.PostgreSQL' -Tag 'PostgreSQL' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.PostgreSQL.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.PostgreSQL.UseSSL' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PostgreSQL.UseSSL' };

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

        It 'Azure.PostgreSQL.MinTLS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PostgreSQL.MinTLS' };

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

        It 'Azure.PostgreSQL.FirewallRuleCount' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PostgreSQL.FirewallRuleCount' };

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

        It 'Azure.PostgreSQL.AllowAzureAccess' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PostgreSQL.AllowAzureAccess' };

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

        It 'Azure.PostgreSQL.FirewallIPRange' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PostgreSQL.FirewallIPRange' };

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

        It 'Azure.PostgreSQL.GeoRedundantBackup' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PostgreSQL.GeoRedundantBackup' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-B', 'server-E', 'server-F', 'server-G', 'server-H', 'server-I';

            $ruleResult[0].Reason | Should -BeExactly "The Azure Database for PostgreSQL 'server-B' should have geo-redundant backup configured.";
            $ruleResult[1].Reason | Should -BeExactly "The Azure Database for PostgreSQL 'server-A' should have geo-redundant backup configured.";
            $ruleResult[2].Reason | Should -BeExactly "The Azure Database for PostgreSQL 'server-E' should have geo-redundant backup configured.";
            $ruleResult[3].Reason | Should -BeExactly "The Azure Database for PostgreSQL 'server-F' should have geo-redundant backup configured.";
           
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-C', 'server-D';
        }

        It 'Azure.PostgreSQL.DefenderCloud' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PostgreSQL.DefenderCloud' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-B';

            $ruleResult[0].Reason | Should -BeExactly "A sub-resource of type 'Microsoft.DBforPostgreSQL/servers/securityAlertPolicies' has not been specified.";
            $ruleResult[1].Reason | Should -BeExactly "Path resources.properties.state: Is set to 'Disabled'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'server-C';
        }

        It 'Azure.PostgreSQL.AAD' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PostgreSQL.AAD' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-B', 'server-D', 'server-E', 'server-G', 'server-H', 'server-I', 'ActiveDirectoryAdmin-A', 'ActiveDirectoryAdmin-C';

            $ruleResult[0].Reason | Should -BeIn 'Path properties.administratorType: Is null or empty.', 'Path properties.login: Is null or empty.', 'Path properties.sid: Is null or empty.';
            $ruleResult[1].Reason | Should -BeIn "A sub-resource of type 'Microsoft.DBforPostgreSQL/servers/administrators' has not been specified.";
            $ruleResult[2].Reason | Should -BeIn "A sub-resource of type 'Microsoft.DBforPostgreSQL/flexibleServers/administrators' has not been specified.";
            $ruleResult[3].Reason | Should -BeIn 'Path properties.principalName: Is null or empty.', 'Path properties.principalType: Is null or empty.';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'server-C', 'server-F', 'ActiveDirectoryAdmin-B', 'ActiveDirectoryAdmin-D';
        }

        It 'Azure.PostgreSQL.AADOnly' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PostgreSQL.AADOnly' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-D', 'server-E';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.authConfig.activeDirectoryAuth'

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'server-F', 'server-G', 'server-H', 'server-I';
        }

        It 'Azure.PostgreSQL.MaintenanceWindow' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PostgreSQL.MaintenanceWindow' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'server-D', 'server-E', 'server-F', 'server-H', 'server-I';

            $ruleResult[0].Reason | Should -BeExactly "Path properties.maintenanceWindow.customWindow: The field 'properties.maintenanceWindow.customWindow' does not exist.";
            $ruleResult[1].Reason | Should -BeExactly "Path properties.maintenanceWindow.customWindow: Is set to 'notset'.";
            $ruleResult[2].Reason | Should -BeExactly "Path properties.maintenanceWindow.customWindow: Is set to 'Disabled'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'server-G';
        }

        It 'Azure.PostgreSQL.ZoneRedundantHA' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PostgreSQL.ZoneRedundantHA' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'server-D', 'server-E', 'server-F', 'server-G';

            $ruleResult[0].Reason | Should -BeExactly "Path sku.tier: The field value 'Burstable' was not included in the set.";
            $ruleResult[1].Reason | Should -BeExactly "Path properties.highAvailability.mode: Is set to 'Disabled'."
            $ruleResult[2].Reason | Should -BeExactly "Path properties.highAvailability.mode: Is set to 'SameZone'.";
            $ruleResult[3].Reason | Should -BeExactly "Path sku.tier: The field value 'Burstable' was not included in the set.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-H', 'server-I';
        }
    }

    Context 'Resource name - Azure.PostgreSQL.ServerName' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.DBforPostgreSQL/servers'
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
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.PostgreSQL.ServerName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.PostgreSQL.ServerName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'Resource naming format' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{
                'AZURE_POSTGRESQL_SERVER_NAME_FORMAT' = '^psql-'
            };

            $names = @('pgserver-001', 'psql-001', 'PSQL-001')
            $items = @($names | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.DBforPostgreSQL/servers'
                    }
                });

            $result = $items | Invoke-PSRule @invokeParams -Option $option -Name 'Azure.PostgreSQL.ServerNaming'
        }

        It 'Azure.PostgreSQL.ServerNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PostgreSQL.ServerNaming' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'pgserver-001', 'PSQL-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'psql-001';
        }
    }
}
