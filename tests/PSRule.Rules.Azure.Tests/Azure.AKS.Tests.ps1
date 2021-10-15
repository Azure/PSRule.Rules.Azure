# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Kubernetes Service rules
#

[CmdletBinding()]
param (

)

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
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.AKS.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.AKS.MinNodeCount' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.MinNodeCount' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'cluster-B', 'cluster-D', 'cluster-F';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -Be 'cluster-A', 'cluster-C', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';
        }

        It 'Azure.AKS.Version' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.Version' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-B';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The Kubernetes version is v1.13.8.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-C', 'cluster-D', 'cluster-F', 'system', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';
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
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -Be 'cluster-A', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';
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
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -Be 'cluster-A', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';
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
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'cluster-C', 'cluster-D', 'cluster-F';
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
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -BeIn 'cluster-C', 'cluster-D', 'cluster-F', 'system', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';
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
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'cluster-C', 'cluster-D', 'cluster-F', 'system';
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
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'cluster-D', 'cluster-F';
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
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'cluster-D', 'cluster-F';
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
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'cluster-C', 'cluster-D', 'cluster-F';
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
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'cluster-D', 'cluster-F';
        }

        It 'Azure.AKS.AutoUpgrade' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AutoUpgrade' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-F';
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
            $ruleResult[4].Reason | Should -BeExactly "The agent pool (agentpool) is not using autoscaling.";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The agent pool (agentpool) is not using autoscaling.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 4;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'system', 'cluster-F';
        }

        It 'Azure.AKS.AuthorizedIPs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AuthorizedIPs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-F';
        }

        It 'Azure.AKS.LocalAccounts' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.LocalAccounts' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';

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
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-F';
        }

        It 'Azure.AKS.CNISubnetSize' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.CNISubnetSize' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 3;
            $ruleResult.TargetName | Should -BeIn 'cluster-B', 'cluster-D', 'system';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The subnet (subnet-A) should be using a minimum size of /23.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The subnet (subnet-A) should be using a minimum size of /23.";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The subnet (subnet-A) should be using a minimum size of /23.";

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
            $ruleResult | Should -HaveCount 3;
            $ruleResult.TargetName | Should -BeIn 'cluster-C', 'cluster-G', 'cluster-H';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (australiaeast) should use following availability zones [3, 2, 1].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (Australia East) should use following availability zones [3, 2, 1].";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (australiaeast) should use following availability zones [3, 2, 1].";

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
            $ruleResult | Should -HaveCount 7;
            $ruleResult.TargetName | Should -BeIn 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';
        }

        It 'Azure.AKS.AuditLogs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AuditLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 7;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H';

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
            $ruleResult | Should -HaveCount 8;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I';

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
    }

    Context 'Resource name' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name = ''
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
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $testObject = [PSCustomObject]@{
                Name = ''
                Properties = [PSCustomObject]@{
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
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
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
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB', 'clusterC/agentpool3', 'clusterC/agentpool4', 'clusterD', 'clusterE';
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
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'clusterB';
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
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterC/agentpool3', 'clusterC/agentpool4', 'clusterD', 'clusterE';
        }

        It 'Azure.AKS.NodeMinPods' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.NodeMinPods' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'clusterA';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterC/agentpool3', 'clusterC/agentpool4', 'clusterD', 'clusterE';
        }

        It 'Azure.AKS.ManagedIdentity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.ManagedIdentity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB', 'clusterD', 'clusterE';
        }

        It 'Azure.AKS.StandardLB' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.StandardLB' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB', 'clusterD', 'clusterE';
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
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'clusterA';
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
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterD', 'clusterE';
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
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterD', 'clusterE';
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
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterC/agentpool4';
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
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterD', 'clusterE';
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
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterD', 'clusterE';
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
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'clusterB', 'clusterD', 'clusterE';
        }

        It 'Azure.AKS.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 3;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB', 'clusterE';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The agent pool (agentpool1) deployed to region (eastus) should use following availability zones [3, 2, 1].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The agent pool (agentpool1) deployed to region (eastus) should use following availability zones [3, 2, 1].";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The agent pool (clusterE/agentpool2) deployed to region (eastus) should use following availability zones [3, 2, 1].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 1;
            $ruleResult.TargetName | Should -BeIn 'clusterD';
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
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB';
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
            $ruleResult[1].Reason | Should -BeExactly "The diagnostic setting (clusterE/Microsoft.Insights/service) logs should enable at least one of (kube-audit, kube-audit-admin) and guard.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 2;
            $ruleResult.TargetName | Should -BeIn 'clusterD', 'clusterE';
        }

        It 'Azure.AKS.PlatformLogs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.PlatformLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 3;
            $ruleResult.TargetName | Should -BeIn 'clusterA', 'clusterB', 'clusterD';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The diagnostic setting (clusterA/Microsoft.Insights/service) logs should enable (cluster-autoscaler, kube-apiserver, kube-controller-manager, kube-scheduler, AllMetrics).";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The diagnostic setting (clusterE/Microsoft.Insights/service) logs should enable (cluster-autoscaler, kube-apiserver, kube-controller-manager, kube-scheduler, AllMetrics).";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The diagnostic setting (clusterD/Microsoft.Insights/service) logs should enable (cluster-autoscaler, kube-apiserver, kube-controller-manager, kube-scheduler, AllMetrics).";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 1;
            $ruleResult.TargetName | Should -BeIn 'clusterE';
        }
    }

    Context 'With Configuration Option' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.AKS.json';
            $configPath = Join-Path -Path $here -ChildPath 'ps-rule-options.yaml';
        }

        It 'Azure.AKS.AvailabilityZone - HashTable option' {
            $option = @{
                'Configuration.AZURE_AKS_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST' = @(
                    [PSCustomObject]@{
                        Location = 'Antarctica North'
                        Zones = @("1", "2", "3")
                    }
                    [PSCustomObject]@{
                        Location = 'Antarctica South'
                        Zones = @("1", "2", "3")
                    }
                )
            }
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $option
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AKS.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 6;
            $ruleResult.TargetName | Should -BeIn 'cluster-C', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (australiaeast) should use following availability zones [3, 2, 1].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The agent pool (system) deployed to region (Antarctica North) should use following availability zones [1, 2, 3].";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (Australia East) should use following availability zones [3, 2, 1].";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (australiaeast) should use following availability zones [3, 2, 1].";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (antarcticanorth) should use following availability zones [1, 2, 3].";
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
            $ruleResult | Should -HaveCount 6;
            $ruleResult.TargetName | Should -BeIn 'cluster-C', 'cluster-F', 'cluster-G', 'cluster-H', 'cluster-I', 'cluster-J';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (australiaeast) should use following availability zones [3, 2, 1].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The agent pool (system) deployed to region (Antarctica North) should use following availability zones [1, 2, 3].";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (Australia East) should use following availability zones [3, 2, 1].";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (australiaeast) should use following availability zones [3, 2, 1].";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (antarcticanorth) should use following availability zones [1, 2, 3].";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The agent pool (agentpool) deployed to region (antarcticasouth) should use following availability zones [1, 2, 3].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult | Should -HaveCount 3;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-D';
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
            $ruleResult | Should -HaveCount 7;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-H';

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
            $ruleResult | Should -HaveCount 7;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-I';

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
            $ruleResult | Should -HaveCount 6;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G';

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
            $ruleResult | Should -HaveCount 7;
            $ruleResult.TargetName | Should -BeIn 'cluster-A', 'cluster-B', 'cluster-C', 'cluster-D', 'cluster-F', 'cluster-G', 'cluster-I';

            
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
    }
}
