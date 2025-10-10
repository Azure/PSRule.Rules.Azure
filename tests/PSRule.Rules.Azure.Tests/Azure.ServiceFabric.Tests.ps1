# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Service Fabric rules
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

Describe 'Azure.ServiceFabric' -Tag 'ServiceFabric' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.ServiceFabric.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.ServiceFabric.AAD' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ServiceFabric.AAD' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-A';
        }

        It 'Azure.ServiceFabric.ProtectionLevel' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ServiceFabric.ProtectionLevel' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'cluster-B';
            $ruleResult.Length | Should -Be 1;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'cluster-A';
            $ruleResult.Length | Should -Be 1;
        }
    }

    Context 'With template' {
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'Resources.ServiceFabric.Template.json';
            $parameterPath = Join-Path -Path $here -ChildPath 'Resources.ServiceFabric.Parameters.json';
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.ServiceFabric.json;
            Export-AzRuleTemplateData -TemplateFile $templatePath -ParameterFile $parameterPath -OutputPath $outputFile;
            $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;
        }

        It 'Azure.ServiceFabric.AAD' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ServiceFabric.AAD' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-001';
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
}
