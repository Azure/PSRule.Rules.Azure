# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Kubernetes Service rules
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

Describe 'Azure.AKS' -Tag AKS {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
                Option        = @{
                    'Configuration.AZURE_AKS_CLUSTER_USER_POOL_EXCLUDED_FROM_MINIMUM_NODES' = @('user-L')
                }
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.AKS.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.AKS.MinNodeCount' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.MinNodeCount' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'cluster-B', 'cluster-D', 'cluster-F', 'cluster-L';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -Be 'cluster-A', 'cluster-C', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-K';
        }

        It 'Azure.AKS.MinUserPoolNodes' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.MinUserPoolNodes' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-I';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 11;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'system', 'cluster-G', 'cluster-H', 'cluster-F', 'cluster-J', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.NodeAutoUpgrade' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.NodeAutoUpgrade' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-K', 'cluster-L';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-F';
        }
        It 'Azure.AKS.Version' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.Version' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-B';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Path Properties.kubernetesVersion: The version '1.13.8' does not match the constraint '>=1.32.5'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 11;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-C', 'cluster-D', 'cluster-F', 'system', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.PoolVersion' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.PoolVersion' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'cluster-B';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The agent pool (agentpool) is running v1.11.4.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -Be 'cluster-A', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.UseRBAC' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.UseRBAC' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'cluster-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -Be 'cluster-A', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.NetworkPolicy' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.NetworkPolicy' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -Be 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.PoolScaleSet' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.PoolScaleSet' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The agent pool (agentpool) is not using scale sets.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The agent pool (agentpool) is not using scale sets.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -BeIn 'cluster-C', 'cluster-D', 'cluster-F', 'system', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.NodeMinPods' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.NodeMinPods' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'cluster-C', 'cluster-D', 'cluster-F', 'system', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.ManagedIdentity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.ManagedIdentity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'cluster-D', 'cluster-F', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.StandardLB' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.StandardLB' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'cluster-D', 'cluster-F', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.AzurePolicyAddOn' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AzurePolicyAddOn' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -Be 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.ManagedAAD' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.ManagedAAD' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'cluster-D', 'cluster-F', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.AutoUpgrade' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AutoUpgrade' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-L';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-F', 'cluster-K';
        }

        It 'Azure.AKS.AutoScaling' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AutoScaling' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 6;
            $ruleResult.TargetName | Should -BeIn 'cluster-C', 'cluster-D', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The agent pool (agentpool) is not using autoscaling.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The agent pool (agentpool) is not using autoscaling.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The agent pool (agentpool) is not using autoscaling.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "The agent pool (agentpool) is not using autoscaling.";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeIn @('The agent pool (system) is not using autoscaling.', 'The agent pool (user) is not using autoscaling.');
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The agent pool (agentpool) is not using autoscaling.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 6;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'system', 'cluster-F', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.AuthorizedIPs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AuthorizedIPs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-K';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-F';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' -and $_.TargetType -eq 'Microsoft.ContainerService/managedClusters' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-L';
        }

        It 'Azure.AKS.LocalAccounts' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.LocalAccounts' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-K', 'cluster-L';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-F';
        }

        It 'Azure.AKS.AzureRBAC' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AzureRBAC' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'cluster-F', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.CNISubnetSize' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.CNISubnetSize' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-B', 'cluster-D';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The subnet (subnet-A) should be using a minimum size of /23.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The subnet (subnet-A) should be using a minimum size of /23.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 7;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-C', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';
        }

        It 'Azure.AKS.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 5;
            $ruleResult.TargetName | Should -BeIn 'cluster-C', 'cluster-G', 'cluster-H', 'cluster-K', 'cluster-L';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (australiaeast) should use following availability zones [1, 2, 3].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (Australia East) should use following availability zones [1, 2, 3].";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (australiaeast) should use following availability zones [1, 2, 3].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 6;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-D', 'cluster-F', 'cluster-I', 'cluster-J';
        }

        It 'Azure.AKS.ContainerInsights' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.ContainerInsights' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 9;
            $ruleResult.TargetName | Should -BeIn 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.AuditLogs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AuditLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 9;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-K', 'cluster-L';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The diagnostic setting (metrics) logs should enable at least one of (kube-audit, kube-audit-admin) and guard.";
            $ruleResult[6].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[6].Reason | Should -BeExactly "The diagnostic setting (metrics) logs should enable at least one of (kube-audit, kube-audit-admin) and guard.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-I', 'cluster-J';
        }

        It 'Azure.AKS.PlatformLogs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.PlatformLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 10;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-K', 'cluster-L';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The diagnostic setting (metrics) logs should enable (cluster-autoscaler, kube-apiserver, kube-controller-manager, kube-scheduler, AllMetrics).";
            $ruleResult[6].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[6].Reason | Should -BeExactly "The diagnostic setting (metrics) logs should enable (cluster-autoscaler, kube-apiserver, kube-controller-manager, kube-scheduler, AllMetrics).";
            $ruleResult[7].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[7].Reason | Should -BeExactly "The diagnostic setting (metrics) logs should enable (cluster-autoscaler, kube-apiserver, kube-controller-manager, kube-scheduler, AllMetrics).";
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-J';
        }

        It 'Azure.AKS.HttpAppRouting' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.HttpAppRouting' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-C', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -Be 'cluster-B', 'cluster-D', 'cluster-J', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.SecretStore' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.SecretStore' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'cluster-F', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.SecretStoreRotation' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.SecretStoreRotation' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-F', 'cluster-K';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-L';
        }

        It 'Azure.AKS.AuditAdmin' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AuditAdmin' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'cluster-I', 'cluster-J';

            $ruleResult[0].Reason | Should -Be "The diagnostic setting (metrics) should use 'kube-audit-admin' instead of the 'kube-audit' log category.";
            $ruleResult[1].Reason | Should -Be "The diagnostic setting (metrics) should use 'kube-audit-admin' instead of the 'kube-audit' log category.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -Be 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-K', 'cluster-L';
        }

        It 'Azure.AKS.MaintenanceWindow' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.MaintenanceWindow' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -Be 'cluster-A', 'cluster-B', 'cluster-D', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-K', 'cluster-L';

            $ruleResult[0].Reason | Should -Be "The cluster (cluster-A) should have the customer-controlled maintenance windows 'aksManagedAutoUpgradeSchedule' and 'aksManagedNodeOSUpgradeSchedule' configured.";
            $ruleResult[1].Reason | Should -Be "The cluster (cluster-B) should have the customer-controlled maintenance windows 'aksManagedAutoUpgradeSchedule' and 'aksManagedNodeOSUpgradeSchedule' configured.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'cluster-C', 'cluster-F';
        }
    }

    Context 'Resource name' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name         = ''
                ResourceType = 'Microsoft.ContainerService/managedClusters'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'cluster1'
                'CLUSTER-1'
                'cluster_1'
                '1-cluster'
            )
            $invalidNames = @(
                '_cluster1'
                '-cluster1'
                'cluster1_'
                'cluster1-'
                'cluster.1'
                'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.AKS.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.AKS.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'DNS prefix' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $testObject = [PSCustomObject]@{
                Name         = ''
                Properties   = [PSCustomObject]@{
                    DNSPrefix = ''
                }
                ResourceType = 'Microsoft.ContainerService/managedClusters'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'cluster1'
                'CLUSTER-1'
                '1-cluster'
            )
            $invalidNames = @(
                '_cluster1'
                '-cluster1'
                'cluster1_'
                'cluster1-'
                'cluster_1'
                'cluster.1'
                'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $testObject.Properties.DNSPrefix = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.AKS.DNSPrefix';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $testObject.Properties.DNSPrefix = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.AKS.DNSPrefix';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'With Template' {
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'Resources.AKS.Template.json';
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.AKS.json;
            Export-AzRuleTemplateData -TemplateFile $templatePath -OutputPath $outputFile;
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
                Option        = @{
                    'Configuration.AZURE_AKS_CLUSTER_USER_POOL_MINIMUM_NODES' = 2
                }
            }
            $result = Invoke-PSRule @invokeParams -InputPath $outputFile -Outcome All;
        }

        It 'Azure.AKS.Version' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.Version' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB', 'clusterC/agentpool3', 'clusterC/agentpool4', 'clusterD', 'clusterE', 'clusterF';
        }

        It 'Azure.AKS.PoolVersion' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.PoolVersion' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterD', 'clusterE';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterF';
        }

        It 'Azure.AKS.PoolScaleSet' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.PoolScaleSet' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'clusterA';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterC/agentpool3', 'clusterC/agentpool4', 'clusterD', 'clusterE', 'clusterF';
        }

        It 'Azure.AKS.NodeMinPods' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.NodeMinPods' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterF';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterC/agentpool3', 'clusterC/agentpool4', 'clusterD', 'clusterE';
        }

        It 'Azure.AKS.MinUserPoolNodes' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.MinUserPoolNodes' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB', 'clusterC/agentpool3', 'clusterC/agentpool4', 'clusterD', 'clusterE', 'clusterF';
        }

        It 'Azure.AKS.ManagedIdentity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.ManagedIdentity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB', 'clusterD', 'clusterE', 'clusterF';
        }

        It 'Azure.AKS.StandardLB' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.StandardLB' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB', 'clusterD', 'clusterE', 'clusterF';
        }

        It 'Azure.AKS.AzurePolicyAddOn' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AzurePolicyAddOn' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterD', 'clusterE';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterF';
        }

        It 'Azure.AKS.ManagedAAD' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.ManagedAAD' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'clusterA';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterD', 'clusterE', 'clusterF';
        }

        It 'Azure.AKS.AutoUpgrade' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AutoUpgrade' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'clusterA';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterD', 'clusterE', 'clusterF';
        }

        It 'Azure.AKS.AutoScaling' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AutoScaling' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 4;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterC/agentpool3', 'clusterD', 'clusterE';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 3;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterC/agentpool4', 'clusterF';
        }

        It 'Azure.AKS.AuthorizedIPs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AuthorizedIPs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'clusterA';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterD', 'clusterE', 'clusterF';
        }

        It 'Azure.AKS.LocalAccounts' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.LocalAccounts' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'clusterA';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterD', 'clusterE', 'clusterF';
        }

        It 'Azure.AKS.AzureRBAC' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AzureRBAC' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'clusterA';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterD', 'clusterE', 'clusterF';
        }

        It 'Azure.AKS.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 3;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB', 'clusterE';

            ($ruleResult | Where-Object { $_.TargetName -eq 'clusterA' }).Reason | Should -Not -BeNullOrEmpty;
            ($ruleResult | Where-Object { $_.TargetName -eq 'clusterA' }).Reason | Should -BeExactly "The agent pool (agentpool1) deployed to region (eastus) should use following availability zones [1, 2, 3].";
            ($ruleResult | Where-Object { $_.TargetName -eq 'clusterB' }).Reason | Should -Not -BeNullOrEmpty;
            ($ruleResult | Where-Object { $_.TargetName -eq 'clusterB' }).Reason | Should -BeExactly "The agent pool (agentpool1) deployed to region (eastus) should use following availability zones [1, 2, 3].";
            ($ruleResult | Where-Object { $_.TargetName -eq 'clusterE' }).Reason | Should -Not -BeNullOrEmpty;
            ($ruleResult | Where-Object { $_.TargetName -eq 'clusterE' }).Reason | Should -BeExactly "The agent pool (clusterE/agentpool2) deployed to region (eastus) should use following availability zones [1, 2, 3].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'clusterD', 'clusterF';
        }

        It 'Azure.AKS.ContainerInsights' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.ContainerInsights' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'clusterD', 'clusterE';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 3;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB', 'clusterF';
        }

        It 'Azure.AKS.AuditLogs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AuditLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The diagnostic setting (clusterA/Microsoft.Insights/service) logs should enable at least one of (kube-audit, kube-audit-admin) and guard.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The diagnostic setting (clusterB/Microsoft.Insights/service) logs should enable at least one of (kube-audit, kube-audit-admin) and guard.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 3;
            $ruleResult.TargetName | Should -BeIn 'clusterD', 'clusterE', 'clusterF';
        }

        It 'Azure.AKS.PlatformLogs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.PlatformLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 3;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB', 'clusterD';

            ($ruleResult | Where-Object { $_.TargetName -eq 'clusterA' }).Reason | Should -Not -BeNullOrEmpty;
            ($ruleResult | Where-Object { $_.TargetName -eq 'clusterA' }).Reason | Should -BeExactly "The diagnostic setting (clusterA/Microsoft.Insights/service) logs should enable (cluster-autoscaler, kube-apiserver, kube-controller-manager, kube-scheduler, AllMetrics).";
            ($ruleResult | Where-Object { $_.TargetName -eq 'clusterB' }).Reason | Should -Not -BeNullOrEmpty;
            ($ruleResult | Where-Object { $_.TargetName -eq 'clusterB' }).Reason | Should -BeExactly "The diagnostic setting (clusterB/Microsoft.Insights/service) logs should enable (cluster-autoscaler, kube-apiserver, kube-controller-manager, kube-scheduler, AllMetrics).";
            ($ruleResult | Where-Object { $_.TargetName -eq 'clusterD' }).Reason | Should -Not -BeNullOrEmpty;
            ($ruleResult | Where-Object { $_.TargetName -eq 'clusterD' }).Reason | Should -BeExactly "The diagnostic setting (clusterD/Microsoft.Insights/service) logs should enable (cluster-autoscaler, kube-apiserver, kube-controller-manager, kube-scheduler, AllMetrics).";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'clusterE', 'clusterF';
        }

        It 'Azure.AKS.HttpAppRouting' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.HttpAppRouting' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'clusterD', 'clusterE', 'clusterF';
        }

        It 'Azure.AKS.SecretStore' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.SecretStore' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'clusterD', 'clusterE', 'clusterF';
        }

        It 'Azure.AKS.SecretStoreRotation' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.SecretStoreRotation' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'clusterD', 'clusterE';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'clusterF';
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
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.AKS.json';
            $configPath = Join-Path -Path $here -ChildPath 'ps-rule-options.yaml';
            $configPath2 = Join-Path -Path $here -ChildPath 'ps-rule-options2.yaml';
        }

        It 'Azure.AKS.Version - HashTable option' {
            # With AZURE_AKS_CLUSTER_MINIMUM_VERSION
            $option = @{
                'Configuration.AZURE_AKS_CLUSTER_MINIMUM_VERSION' = '9.99.9'
            }
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $option
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.Version' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 10;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'system';
            $ruleResult.Reason | Should -Not -BeNullOrEmpty;
            $ruleResult.Reason | Should -BeLike "Path Properties.*Version: The version '*' does not match the constraint '>=9.99.9'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-L', 'cluster-K';

            # With Azure_AKSMinimumVersion
            $option = @{
                'Configuration.AZURE_AKS_CLUSTER_MINIMUM_VERSION' = '1.0.0'
                'Configuration.Azure_AKSMinimumVersion'           = '9.99.9'
            }
            $invokeOldParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'SilentlyContinue'
                ErrorAction   = 'Stop'
            }
            $result = Invoke-PSRule @invokeOldParams -InputPath $dataPath -Option $option -WarningVariable outWarn;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.Version' };
            $warnings = @($outWarn | Where-Object {
                    $_ -like '*Azure_AKSMinimumVersion*'
                })
            $warnings | Should -HaveCount 1;
            $warnings | Should -BeExactly "The configuration option 'Azure_AKSMinimumVersion' has been replaced with 'AZURE_AKS_CLUSTER_MINIMUM_VERSION'. The option 'Azure_AKSMinimumVersion' is deprecated and will no longer work in the next major version. Please update your configuration to the new name. See https://aka.ms/ps-rule-azure/upgrade.";

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 10;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'system';
            $ruleResult.Reason | Should -Not -BeNullOrEmpty;
            $ruleResult.Reason | Should -BeLike "Path Properties.*Version: The version '*' does not match the constraint '>=9.99.9'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-L', 'cluster-K';
        }

        It 'Azure.AKS.Version - YAML file option' {
            # With AZURE_AKS_CLUSTER_MINIMUM_VERSION
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $configPath
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.Version' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 10;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-K', 'system';
            $ruleResult.Reason | Should -Not -BeNullOrEmpty;
            $ruleResult.Reason | Should -BeLike "Path Properties.*Version: The version '*' does not match the constraint '>=9.99.9'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-L', 'cluster-K';

            # With Azure_AKSMinimumVersion
            $invokeOldParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'SilentlyContinue'
                ErrorAction   = 'Stop'
            }
            $result = Invoke-PSRule @invokeOldParams -InputPath $dataPath -Option $configPath2 -WarningVariable outWarn;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.Version' };
            $warnings = @($outWarn | Where-Object {
                    $_ -like '*Azure_AKSMinimumVersion*'
                })
            $warnings | Should -HaveCount 1;
            $warnings | Should -BeExactly "The configuration option 'Azure_AKSMinimumVersion' has been replaced with 'AZURE_AKS_CLUSTER_MINIMUM_VERSION'. The option 'Azure_AKSMinimumVersion' is deprecated and will no longer work in the next major version. Please update your configuration to the new name. See https://aka.ms/ps-rule-azure/upgrade.";

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 10;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'system';
            $ruleResult.Reason | Should -Not -BeNullOrEmpty;
            $ruleResult.Reason | Should -BeLike "Path Properties.*Version: The version '*' does not match the constraint '>=9.99.9'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-L', 'cluster-K';
        }

        It 'Azure.AKS.AvailabilityZone - HashTable option' {
            $option = @{
                'Configuration.AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST' = @(
                    [PSCustomObject]@{
                        Location = 'Antarctica North'
                        Zones    = @("1", "2", "3")
                    }
                    [PSCustomObject]@{
                        Location = 'Antarctica South'
                        Zones    = @("1", "2", "3")
                    }
                )
            }
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $option
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 8;
            $ruleResult.TargetName | Should -BeIn 'cluster-C', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-K', 'cluster-L';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (australiaeast) should use following availability zones [1, 2, 3].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The agent pool (system) deployed to region (Antarctica North) should use following availability zones [1, 2, 3].";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (Australia East) should use following availability zones [1, 2, 3].";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (australiaeast) should use following availability zones [1, 2, 3].";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeIn @("The agent pool (system) deployed to region (antarcticanorth) should use following availability zones [1, 2, 3].", "The agent pool (user) deployed to region (antarcticanorth) should use following availability zones [1, 2, 3].");
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (antarcticasouth) should use following availability zones [1, 2, 3].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 3;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-D';
        }

        It 'Azure.AKS.AvailabilityZone - YAML file option' {
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $configPath
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 8;
            $ruleResult.TargetName | Should -BeIn 'cluster-C', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-K', 'cluster-L';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (australiaeast) should use following availability zones [1, 2, 3].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The agent pool (system) deployed to region (Antarctica North) should use following availability zones [1, 2, 3].";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (Australia East) should use following availability zones [1, 2, 3].";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (australiaeast) should use following availability zones [1, 2, 3].";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeIn @('The agent pool (system) deployed to region (antarcticanorth) should use following availability zones [1, 2, 3].', 'The agent pool (user) deployed to region (antarcticanorth) should use following availability zones [1, 2, 3].');
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (antarcticasouth) should use following availability zones [1, 2, 3].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 3;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-D';
        }

        It 'Azure.AKS.NodeMinPods - HashTable option' {
            $option = @{
                'Configuration.AZURE_AKS_POOL_MINIMUM_MAXPODS' = 30
            }

            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $option
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.NodeMinPods' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 11;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-K', 'cluster-L', 'system';
        }

        It 'Azure.AKS.PlatformLogs - HashTable option - Excluding metrics category' {
            $option = @{
                'Configuration.AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST' = @(
                    'cluster-autoscaler', 
                    'kube-apiserver', 
                    'kube-controller-manager', 
                    'kube-scheduler'
                )
            }

            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $option
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.PlatformLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 9;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-K', 'cluster-L';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The diagnostic setting (metrics) logs should enable (cluster-autoscaler, kube-apiserver, kube-controller-manager, kube-scheduler).";
            $ruleResult[6].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[6].Reason | Should -BeExactly "The diagnostic setting (metrics) logs should enable (cluster-autoscaler, kube-apiserver, kube-controller-manager, kube-scheduler).";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-I', 'cluster-J';
        }

        It 'Azure.AKS.PlatformLogs - HashTable option - Excluding metrics category' {
            $option = @{
                'Configuration.AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST' = @(
                    'cluster-autoscaler', 
                    'kube-apiserver', 
                    'kube-controller-manager',
                    'AllMetrics'
                )
            }

            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $option
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.PlatformLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 9;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-I', 'cluster-K', 'cluster-L';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The diagnostic setting (metrics) logs should enable (cluster-autoscaler, kube-apiserver, kube-controller-manager, AllMetrics).";
            $ruleResult[6].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[6].Reason | Should -BeExactly "The diagnostic setting (metrics) logs should enable (cluster-autoscaler, kube-apiserver, kube-controller-manager, AllMetrics).";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-H', 'cluster-J';
        }

        It 'Azure.AKS.PlatformLogs - HashTable option - Excluding metrics and log category' {
            $option = @{
                'Configuration.AZURE_AKS_ENABLED_PLATFORM_LOG_CATEGORIES_LIST' = @(
                    'cluster-autoscaler', 
                    'kube-apiserver', 
                    'kube-controller-manager'
                )
            }

            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $option
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.PlatformLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 8;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-K', 'cluster-L';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The diagnostic setting (metrics) logs should enable (cluster-autoscaler, kube-apiserver, kube-controller-manager).";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 3;
            $ruleResult.TargetName | Should -BeIn 'cluster-H', 'cluster-I', 'cluster-J';
        }

        It 'Azure.AKS.PlatformLogs - YAML file option - Excluding metrics and log categories' {
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $configPath
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.PlatformLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 9;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-I', 'cluster-K', 'cluster-L';

            
            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "Diagnostic settings are not configured.";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The diagnostic setting (metrics) logs should enable (cluster-autoscaler, AllMetrics).";
            $ruleResult[6].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[6].Reason | Should -BeExactly "The diagnostic setting (metrics) logs should enable (cluster-autoscaler, AllMetrics).";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-H', 'cluster-J';
        }
        
        It 'Azure.AKS.UptimeSLA' {
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.UptimeSLA' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'sku.tier';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'cluster-I', 'cluster-J', 'cluster-K', 'cluster-L';  
        }

        It 'Azure.AKS.EphemeralOSDisk' {
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.EphemeralOSDisk' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-F', 'cluster-K';

            $ruleResult[0].Reason | Should -BeExactly "The OS disk type 'Managed' should be of type 'Ephemeral'.";
            $ruleResult[1].Reason | Should -BeExactly "The OS disk type 'Managed' should be of type 'Ephemeral'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'system', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J', 'cluster-L';
        }

        It 'Azure.AKS.DefenderProfile' {
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.DefenderProfile' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-K', 'cluster-L';

            $ruleResult[0].Reason | Should -BeExactly "Path properties.securityProfile.defender.securityMonitoring.enabled: The field 'properties.securityProfile.defender.securityMonitoring.enabled' does not exist.";
            $ruleResult[1].Reason | Should -BeExactly "Path properties.securityProfile.defender.securityMonitoring.enabled: Is set to 'False'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-D', 'cluster-J';
        }
    }
}
