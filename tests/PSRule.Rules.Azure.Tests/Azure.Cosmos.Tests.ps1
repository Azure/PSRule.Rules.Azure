# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Cosmos DB rules
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

Describe 'Azure.Cosmos' -Tag 'Cosmos', 'CosmosDB' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Cosmos.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.Cosmos.DisableMetadataWrite' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.DisableMetadataWrite' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'graph-A', 'nosql-A', 'nosql-B', 'nosql-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'graph-B';
        }

        It 'Azure.Cosmos.MinTLS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.MinTLS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'graph-B', 'nosql-A', 'nosql-B', 'nosql-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'graph-A';
        }

        It 'Azure.Cosmos.SLA' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.SLA' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'graph-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'graph-B', 'nosql-A', 'nosql-B', 'nosql-C';
        }

        It 'Azure.Cosmos.DisableLocalAuth' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.DisableLocalAuth' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'nosql-A', 'nosql-B';
            
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'nosql-C';
        }

        It 'Azure.Cosmos.PublicAccess' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.PublicAccess' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'graph-A', 'graph-B', 'nosql-A', 'nosql-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'nosql-C';
        }

        It 'Azure.Cosmos.ContinuousBackup' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.ContinuousBackup' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'graph-A', 'graph-B';

            $ruleResult[0].Reason | Should -Be "Path properties.backupPolicy.type: The field 'properties.backupPolicy.type' does not exist.";
            $ruleResult[1].Reason | Should -Be "Path properties.backupPolicy.type: Is set to 'Periodic'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'nosql-A', 'nosql-B', 'nosql-C';
        }
    }

    Context 'Resource name - Azure.Cosmos.AccountName' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name         = ''
                ResourceType = 'Microsoft.DocumentDb/databaseAccounts'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'db1'
                'db-1'
            )

            $invalidNames = @(
                '_db1'
                '-db1'
                'db.1'
                'db-'
                'db'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.Cosmos.AccountName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.Cosmos.AccountName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'With template' {
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'Resources.Cosmos.Parameters.*.json?';
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Option        = (Join-Path -Path $here -ChildPath 'test-template-options.yaml')
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $result = Invoke-PSRule @invokeParams -InputPath $templatePath;
        }

        It 'Azure.Cosmos.DisableMetadataWrite' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.DisableMetadataWrite' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'gremlin-002';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'gremlin-001';
        }
    }

    Context 'With Configuration Option' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Cosmos.json';
            $configPath = Join-Path -Path $here -ChildPath 'ps-rule-options.yaml';
        }
        
        It 'Azure.Cosmos.DefenderCloud -  YAML file option' {
            # With AZURE_COSMOS_DEFENDER_PER_ACCOUNT
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $configPath
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.DefenderCloud' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'nosql-A', 'nosql-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'nosql-C';
        }
    }

    Context 'Resource naming' {
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
                'AZURE_COSMOS_CASSANDRA_NAME_FORMAT'   = '^coscas-'
                'AZURE_COSMOS_TABLE_NAME_FORMAT'       = '^costab-'
                'AZURE_COSMOS_GREMLIN_NAME_FORMAT'     = '^cosgrm-'
                'AZURE_COSMOS_DATABASE_NAME_FORMAT'    = '^cosmos-'
                'AZURE_COSMOS_POSTGRESQL_NAME_FORMAT'  = '^cospos-'
            };

            $nosqlNames = @('account-001', 'cosno-001', 'COSNO-001')
            $mongoNames = @('mongo-001', 'cosmon-001', 'COSMON-001')
            $cassandraNames = @('cassandra-001', 'coscas-001', 'COSCAS-001')
            $tableNames = @('table-001', 'costab-001', 'COSTAB-001')
            $gremlinNames = @('gremlin-001', 'cosgrm-001', 'COSGRM-001')
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

            $cassandraItems = @($cassandraNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name       = $_
                        Type       = 'Microsoft.DocumentDb/databaseAccounts'
                        Kind       = 'GlobalDocumentDB'
                        Properties = @{
                            capabilities = @(@{ name = 'EnableCassandra' })
                        }
                    }
                });

            $tableItems = @($tableNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name       = $_
                        Type       = 'Microsoft.DocumentDb/databaseAccounts'
                        Kind       = 'GlobalDocumentDB'
                        Properties = @{
                            capabilities = @(@{ name = 'EnableTable' })
                        }
                    }
                });

            $gremlinItems = @($gremlinNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name       = $_
                        Type       = 'Microsoft.DocumentDb/databaseAccounts'
                        Kind       = 'GlobalDocumentDB'
                        Properties = @{
                            capabilities = @(@{ name = 'EnableGremlin' })
                        }
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

            $result = @($nosqlItems + $mongoItems + $cassandraItems + $tableItems + $gremlinItems + $dbItems + $postgresItems) | Invoke-PSRule @invokeParams -Option $option
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

        It 'Azure.Cosmos.CassandraNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.CassandraNaming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'cassandra-001', 'COSCAS-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'coscas-001';
        }

        It 'Azure.Cosmos.TableNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.TableNaming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'table-001', 'COSTAB-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'costab-001';
        }

        It 'Azure.Cosmos.GremlinNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.GremlinNaming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'gremlin-001', 'COSGRM-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'cosgrm-001';
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
}
