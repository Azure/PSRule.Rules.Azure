# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Container Registry rules
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

Describe 'Azure.ACR' -Tag 'ACR' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
                Outcome = 'All'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.ACR.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.ACR.AdminUser' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ACR.AdminUser' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'registry-A', 'registry-D';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'Properties.adminUserEnabled';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -BeIn 'registry-B', 'registry-C', 'registry-E', 'registry-F', 'registry-G', 'registry-H', 'registry-I', 'registry-J';
        }

        It 'Azure.ACR.MinSku' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ACR.MinSku' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'registry-A';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'Sku.name';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -BeIn 'registry-B', 'registry-C', 'registry-D', 'registry-E', 'registry-F', 'registry-G', 'registry-H', 'registry-I', 'registry-J';
        }

        It 'Azure.ACR.Quarantine' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ACR.Quarantine' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -BeIn 'registry-A', 'registry-B', 'registry-D', 'registry-F', 'registry-G', 'registry-H', 'registry-I', 'registry-J';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'Properties.policies.quarantinePolicy.status';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'registry-C', 'registry-E';
        }

        It 'Azure.ACR.ContentTrust' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ACR.ContentTrust' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'registry-D';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'Properties.policies.trustPolicy.status';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'registry-E', 'registry-I';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'registry-A', 'registry-B', 'registry-C', 'registry-F', 'registry-G', 'registry-H', 'registry-J';
        }

        It 'Azure.ACR.Retention' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ACR.Retention' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'registry-D', 'registry-J', 'registry-I';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'Properties.policies.retentionPolicy.status';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'registry-E';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'registry-A', 'registry-B', 'registry-C', 'registry-F', 'registry-G', 'registry-H';
        }

        It 'Azure.ACR.Usage' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ACR.Usage' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'registry-B', 'registry-E';
            # TODO: $ruleResult.Detail.Reason.Path | Should -BeIn '';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -BeIn 'registry-A', 'registry-C', 'registry-D', 'registry-F', 'registry-G', 'registry-H', 'registry-I', 'registry-J';
        }

        It 'Azure.ACR.ContainerScan' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ACR.ContainerScan' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'registry-A', 'registry-D', 'registry-F', 'registry-G', 'registry-H', 'registry-I', 'registry-J';
            # TODO: $ruleResult.Detail.Reason.Path | Should -BeIn 'resources';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The results for a valid assessment was not found.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'registry-B', 'registry-C', 'registry-E';
        }

        It 'Azure.ACR.ImageHealth' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ACR.ImageHealth' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'registry-B', 'registry-E';
            # TODO: $ruleResult.Detail.Reason.Path | Should -BeIn '';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "An assessment is reporting one or more issues.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'registry-C';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'registry-A', 'registry-D', 'registry-F', 'registry-G', 'registry-H', 'registry-I', 'registry-J';
        }

        It 'Azure.ACR.GeoReplica' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ACR.GeoReplica' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'registry-A', 'registry-D', 'registry-F', 'registry-G', 'registry-H', 'registry-I', 'registry-J';
            # TODO: $ruleResult.Detail.Reason.Path | Should -BeIn '';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "A replica in a secondary region was not found.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'registry-B', 'registry-C', 'registry-E';
        }

        It 'Azure.ACR.SoftDelete' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.ACR.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ACR.SoftDelete' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'registry-A', 'registry-D', 'registry-H';

            $ruleResult[0].Reason | Should -BeExactly "The container registry 'registry-A' should have soft delete policy enabled.", "The container registry 'registry-A' should have retention period value between one to 90 days for the soft delete policy.";
            $ruleResult[1].Reason | Should -BeExactly "The container registry 'registry-D' should have soft delete policy enabled.", "The container registry 'registry-D' should have retention period value between one to 90 days for the soft delete policy.";
            $ruleResult[2].Reason | Should -BeExactly "The container registry 'registry-H' should have soft delete policy enabled.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'registry-G', 'registry-I', 'registry-J';
        }

        It 'Azure.ACR.AnonymousAccess' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ACR.AnonymousAccess' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'registry-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.anonymousPullEnabled';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -BeIn 'registry-C', 'registry-D', 'registry-E', 'registry-F', 'registry-G', 'registry-H', 'registry-I', 'registry-J';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'registry-A';
        }

        It 'Azure.ACR.Firewall' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ACR.Firewall' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'registry-D', 'registry-E';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.publicNetworkAccess', 'properties.networkRuleSet.defaultAction';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'registry-I', 'registry-J';
            
            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'registry-A', 'registry-B', 'registry-C', 'registry-F', 'registry-G', 'registry-H';
        }

        It 'Azure.ACR.ExportPolicy' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ACR.ExportPolicy' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'registry-K', 'registry-L';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.policies.exportPolicy.status', 'properties.publicNetworkAccess';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'registry-M';
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
                ResourceType = 'Microsoft.ContainerRegistry/registries'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'registry1'
                'REGISTRY001'
            )
            $invalidNames = @(
                '_registry1'
                '-registry1'
                'registry1_'
                'registry1-'
                'registry-1'
                'acr1'
                'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.ACR.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.ACR.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'name';
        }
    }
}
