# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for new naming rules
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

Describe 'Azure.Naming' -Tag 'Naming' {
    Context 'Container Instance naming' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{
                'AZURE_CONTAINER_INSTANCE_NAME_FORMAT' = '^ci-'
            };

            $names = @('instance-001', 'ci-001', 'CI-001')
            $items = @($names | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.ContainerInstance/containerGroups'
                    }
                });

            $result = $items | Invoke-PSRule @invokeParams -Option $option
        }

        It 'Azure.CI.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.CI.Naming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'instance-001', 'CI-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'ci-001';
        }
    }

    Context 'Service Fabric naming' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{
                'AZURE_SERVICE_FABRIC_CLUSTER_NAME_FORMAT'         = '^sf-'
                'AZURE_SERVICE_FABRIC_MANAGED_CLUSTER_NAME_FORMAT' = '^sfmc-'
            };

            $clusterNames = @('cluster-001', 'sf-001', 'SF-001')
            $managedClusterNames = @('managed-001', 'sfmc-001', 'SFMC-001')

            $clusterItems = @($clusterNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.ServiceFabric/clusters'
                    }
                });

            $managedClusterItems = @($managedClusterNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.ServiceFabric/managedClusters'
                    }
                });

            $result = @($clusterItems + $managedClusterItems) | Invoke-PSRule @invokeParams -Option $option
        }

        It 'Azure.ServiceFabric.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ServiceFabric.Naming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-001', 'SF-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'sf-001';
        }

        It 'Azure.ServiceFabric.ManagedNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ServiceFabric.ManagedNaming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'managed-001', 'SFMC-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'sfmc-001';
        }
    }

    Context 'Cosmos DB naming' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{
                'AZURE_COSMOS_NOSQL_NAME_FORMAT'       = '^cosno-'
                'AZURE_COSMOS_MONGO_NAME_FORMAT'       = '^cosmon-'
                'AZURE_COSMOS_DATABASE_NAME_FORMAT'    = '^cosmos-'
                'AZURE_COSMOS_POSTGRESQL_NAME_FORMAT'  = '^cospos-'
            };

            $nosqlNames = @('account-001', 'cosno-001', 'COSNO-001')
            $mongoNames = @('mongo-001', 'cosmon-001', 'COSMON-001')
            $dbNames = @('db-001', 'cosmos-001', 'COSMOS-001')
            $postgresNames = @('postgres-001', 'cospos-001', 'COSPOS-001')

            $nosqlItems = @($nosqlNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name       = $_
                        Type       = 'Microsoft.DocumentDb/databaseAccounts'
                        Kind       = 'GlobalDocumentDB'
                        Properties = @{
                            capabilities = @()
                        }
                    }
                });

            $mongoItems = @($mongoNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name       = $_
                        Type       = 'Microsoft.DocumentDb/databaseAccounts'
                        Kind       = 'MongoDB'
                        Properties = @{ }
                    }
                });

            $dbItems = @($dbNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases'
                    }
                });

            $postgresItems = @($postgresNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.DBforPostgreSQL/serverGroupsv2'
                    }
                });

            $result = @($nosqlItems + $mongoItems + $dbItems + $postgresItems) | Invoke-PSRule @invokeParams -Option $option
        }

        It 'Azure.Cosmos.NoSQLNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.NoSQLNaming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'account-001', 'COSNO-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'cosno-001';
        }

        It 'Azure.Cosmos.MongoNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.MongoNaming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'mongo-001', 'COSMON-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'cosmon-001';
        }

        It 'Azure.Cosmos.DatabaseNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.DatabaseNaming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'db-001', 'COSMOS-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'cosmos-001';
        }

        It 'Azure.Cosmos.PostgreSQLNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.PostgreSQLNaming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'postgres-001', 'COSPOS-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'cospos-001';
        }
    }

    Context 'Redis naming' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{
                'AZURE_REDIS_CACHE_NAME_FORMAT'      = '^redis-'
                'AZURE_REDIS_ENTERPRISE_NAME_FORMAT' = '^amr-'
            };

            $cacheNames = @('cache-001', 'redis-001', 'REDIS-001')
            $enterpriseNames = @('enterprise-001', 'amr-001', 'AMR-001')

            $cacheItems = @($cacheNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.Cache/Redis'
                    }
                });

            $enterpriseItems = @($enterpriseNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.Cache/RedisEnterprise'
                    }
                });

            $result = @($cacheItems + $enterpriseItems) | Invoke-PSRule @invokeParams -Option $option
        }

        It 'Azure.Redis.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Redis.Naming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'cache-001', 'REDIS-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'redis-001';
        }

        It 'Azure.RedisEnterprise.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.RedisEnterprise.Naming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'enterprise-001', 'AMR-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'amr-001';
        }
    }

    Context 'SQL naming' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{
                'AZURE_SQL_SERVER_NAME_FORMAT'       = '^sql-'
                'AZURE_SQL_DATABASE_NAME_FORMAT'     = '^sqldb-'
                'AZURE_SQL_MI_NAME_FORMAT'           = '^sqlmi-'
                'AZURE_MYSQL_SERVER_NAME_FORMAT'     = '^mysql-'
                'AZURE_POSTGRESQL_SERVER_NAME_FORMAT'= '^psql-'
            };

            $serverNames = @('server-001', 'sql-001', 'SQL-001')
            $dbNames = @('database-001', 'sqldb-001', 'SQLDB-001')
            $miNames = @('mi-001', 'sqlmi-001', 'SQLMI-001')
            $mysqlNames = @('myserver-001', 'mysql-001', 'MYSQL-001')
            $postgresNames = @('pgserver-001', 'psql-001', 'PSQL-001')

            $serverItems = @($serverNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.Sql/servers'
                    }
                });

            $dbItems = @($dbNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.Sql/servers/databases'
                    }
                });

            $miItems = @($miNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.Sql/managedInstances'
                    }
                });

            $mysqlItems = @($mysqlNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.DBforMySQL/servers'
                    }
                });

            $postgresItems = @($postgresNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.DBforPostgreSQL/servers'
                    }
                });

            $result = @($serverItems + $dbItems + $miItems + $mysqlItems + $postgresItems) | Invoke-PSRule @invokeParams -Option $option
        }

        It 'Azure.SQL.ServerNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.SQL.ServerNaming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-001', 'SQL-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'sql-001';
        }

        It 'Azure.SQL.DatabaseNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.SQL.DatabaseNaming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'database-001', 'SQLDB-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'sqldb-001';
        }

        It 'Azure.SQLMI.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.SQLMI.Naming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'mi-001', 'SQLMI-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'sqlmi-001';
        }

        It 'Azure.MySQL.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.MySQL.Naming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'myserver-001', 'MYSQL-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'mysql-001';
        }

        It 'Azure.PostgreSQL.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.PostgreSQL.Naming' };
            
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
