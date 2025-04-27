# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure subscription rules
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
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.Subscription.json';
}

Describe 'Azure.RBAC' -Tag 'Subscription', 'RBAC' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.RBAC.UseGroups' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.RBAC.UseGroups' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'subscription-B', 'subscription-C';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The number of assignments is 6.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The number of assignments is 6.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -BeIn 1;
            $ruleResult.TargetName | Should -BeIn 'subscription-A';
        }

        It 'Azure.RBAC.LimitOwner' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.RBAC.LimitOwner' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'subscription-B';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The number of assignments is 6.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'subscription-A', 'subscription-C';
        }

        It 'Azure.RBAC.LimitMGDelegation' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.RBAC.LimitMGDelegation' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'subscription-C';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The number of assignments is 4.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'subscription-B', 'subscription-A';
        }

        It 'Azure.RBAC.CoAdministrator' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.RBAC.CoAdministrator' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'subscription-C';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The number of assignments is 1.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'subscription-B', 'subscription-A';
        }

        It 'Azure.RBAC.UseRGDelegation' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.RBAC.UseRGDelegation' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'test-rg-B';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The number of assignments is 1.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'test-rg-A';
        }

        It 'Azure.RBAC.PIM' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.RBAC.PIM' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'subscription-B', 'subscription-C';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The subscription is not managed.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The subscription is not managed.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'subscription-A';
        }
    }

    Context 'Required tags' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{
                'AZURE_SUBSCRIPTION_REQUIRED_TAGS' = @('tag1', 'tag2');
                'AZURE_TAG_FORMAT_FOR_TAG1' = '^tag1$';
                'AZURE_TAG_FORMAT_FOR_TAG2' = '^tag2$'
            };

            $items = @(
                [PSCustomObject]@{
                    Name         = 'rg-test-1'
                    Type         = 'Microsoft.Subscription/aliases'
                    Properties   = [PSCustomObject]@{
                        AdditionalProperties = [PSCustomObject]@{
                            tags = @{ tag1 = 'tag1'; tag2 = 'tag2'; tag3 = 'tag3' }
                        }
                    }
                }
                [PSCustomObject]@{
                    Name         = 'rg-test-2'
                    Type         = 'Microsoft.Subscription/aliases'
                    Properties   = [PSCustomObject]@{
                        AdditionalProperties = [PSCustomObject]@{
                            Tags = @{ tag1 = 'tag1'; tag2 = 'invalid' }
                        }
                    }
                }
                [PSCustomObject]@{
                    Name         = 'rg-test-3'
                    Type         = 'Microsoft.Subscription/aliases'
                    Properties   = [PSCustomObject]@{
                        AdditionalProperties = [PSCustomObject]@{
                            Tags = @{ tag1 = 'invalid'; tag2 = 'invalid' }
                        }
                    }
                }
                [PSCustomObject]@{
                    Name         = 'rg-test-4'
                    Type         = 'Microsoft.Subscription/aliases'
                    Properties   = [PSCustomObject]@{
                        AdditionalProperties = [PSCustomObject]@{
                            Tags         = @{ Tag1 = 'tag1'; tag2 = 'tag2' }
                        }
                    }
                }
            )

            $result = $items | Invoke-PSRule @invokeParams -Option $option -Name 'Azure.Subscription.RequiredTags'
        }

        It 'Azure.Subscription.RequiredTags' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Subscription.RequiredTags' };
            $validNames = @(
                'rg-test-1'
            )

            $invalidNames = @(
                'rg-test-2'
                'rg-test-3'
                'rg-test-4'
            )

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn $invalidNames;
            $ruleResult | Should -HaveCount $invalidNames.Length;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn $validNames;
            $ruleResult | Should -HaveCount $validNames.Length;
        }
    }
}

Describe 'Azure.DefenderCloud' -Tag 'Subscription', 'DefenderCloud', 'defender' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.Defender.SecurityContact' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Defender.SecurityContact' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'subscription-B', 'subscription-A';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -HaveCount 1;
            $ruleResult[0].Reason | Should -BeIn @(
                "Path properties.emails: Does not exist."
            );
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -HaveCount 1;
            $ruleResult[1].Reason | Should -BeIn @(
                "Path properties.emails: Is null or empty."
            );

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'subscription-C';
        }

        It 'Azure.DefenderCloud.Provisioning' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.DefenderCloud.Provisioning' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'subscription-B', 'subscription-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'subscription-A';
        }
    }
}


Describe 'Azure.Monitor' -Tag 'Subscription', 'Monitor' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.Monitor.ServiceHealth' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Monitor.ServiceHealth' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'subscription-A', 'subscription-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'subscription-B';
        }
    }
}
