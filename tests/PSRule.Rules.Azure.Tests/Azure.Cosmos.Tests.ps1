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
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -Be 'graph-A', 'nosql-A', 'nosql-B', 'nosql-C', 'nosql-D', 'nosql-E';

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
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'graph-A', 'nosql-D', 'nosql-E';
        }

        It 'Azure.Cosmos.SLA' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.SLA' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'graph-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'graph-B', 'nosql-A', 'nosql-B', 'nosql-C', 'nosql-D', 'nosql-E';
        }

        It 'Azure.Cosmos.DisableLocalAuth' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.DisableLocalAuth' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'nosql-A', 'nosql-B', 'nosql-D', 'nosql-E';
            
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'nosql-C';
        }

        It 'Azure.Cosmos.PublicAccess' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.PublicAccess' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'graph-A', 'graph-B', 'nosql-A', 'nosql-B', 'nosql-D', 'nosql-E';

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
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'nosql-A', 'nosql-B', 'nosql-C', 'nosql-D', 'nosql-E';
        }

        It 'Azure.Cosmos.MongoEntraID' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.MongoEntraID' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'mongodb-a';

            $ruleResult[0].Reason | Should -Be "Path properties.authConfig.allowedModes[*]: The value 'System.String[]' does not contain any of 'System.String[]'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'mongodb-b', 'mongodb-c';
        }

        It 'Azure.Cosmos.AvailabilityZone' {
            # Test scenarios covered:
            # FAIL scenarios:
            #   - nosql-A: Multi-region (East US + West US), primary region supports AZ but disabled
            #   - nosql-E: Single region (East US), supports AZ but disabled
            # PASS scenarios:
            #   - nosql-D: Single region (East US), supports AZ and enabled
            #   - nosql-B, nosql-C: Single region (West US), does not support AZ (no requirement)
            #   - graph-A, graph-B: Single region (East US), supports AZ and enabled

            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Cosmos.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'nosql-A', 'nosql-E';

            # nosql-A: Multi-region (East US + West US), primary region supports AZ but disabled - FAIL
            $nosqlA = $ruleResult | Where-Object { $_.TargetName -eq 'nosql-A' };
            $nosqlA | Should -Not -BeNullOrEmpty;
            $nosqlA.Outcome | Should -Be 'Fail';

            # nosql-E: Single region (East US) supports AZ but disabled - FAIL
            $nosqlE = $ruleResult | Where-Object { $_.TargetName -eq 'nosql-E' };
            $nosqlE | Should -Not -BeNullOrEmpty;
            $nosqlE.Outcome | Should -Be 'Fail';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'graph-A', 'graph-B', 'nosql-B', 'nosql-C', 'nosql-D';

            # nosql-D: Single region (East US) supports AZ and enabled - PASS
            $nosqlD = $ruleResult | Where-Object { $_.TargetName -eq 'nosql-D' };
            $nosqlD | Should -Not -BeNullOrEmpty;
            $nosqlD.Outcome | Should -Be 'Pass';

            # nosql-B, nosql-C: Single region (West US) does not support AZ - PASS (no requirement)
            $nosqlB = $ruleResult | Where-Object { $_.TargetName -eq 'nosql-B' };
            $nosqlB | Should -Not -BeNullOrEmpty;
            $nosqlB.Outcome | Should -Be 'Pass';

            $nosqlC = $ruleResult | Where-Object { $_.TargetName -eq 'nosql-C' };
            $nosqlC | Should -Not -BeNullOrEmpty;
            $nosqlC.Outcome | Should -Be 'Pass';

            # graph-A, graph-B: Single region (East US) supports AZ and enabled - PASS
            $graphA = $ruleResult | Where-Object { $_.TargetName -eq 'graph-A' };
            $graphA | Should -Not -BeNullOrEmpty;
            $graphA.Outcome | Should -Be 'Pass';

            $graphB = $ruleResult | Where-Object { $_.TargetName -eq 'graph-B' };
            $graphB | Should -Not -BeNullOrEmpty;
            $graphB.Outcome | Should -Be 'Pass';
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
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'nosql-A', 'nosql-B', 'nosql-D', 'nosql-E';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'nosql-C';
        }
    }
}
