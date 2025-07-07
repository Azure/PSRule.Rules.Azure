# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Event Grid rules
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

Describe 'Azure.EventGrid' -Tag 'EventGrid' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.EventGrid.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.EventGrid.TopicPublicAccess' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventGrid.TopicPublicAccess' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'topic-A', 'topic-B';
            $ruleResult.Length | Should -Be 2;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'topic-C', 'domain-A', 'domain-B';
            $ruleResult.Length | Should -Be 3;
        }

        It 'Azure.EventGrid.ManagedIdentity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventGrid.ManagedIdentity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'topic-A';
            $ruleResult.Length | Should -Be 1;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'topic-B', 'topic-C', 'domain-A', 'domain-B';
            $ruleResult.Length | Should -Be 4;
        }

        It 'Azure.EventGrid.DisableLocalAuth' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventGrid.DisableLocalAuth' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'topic-A', 'topic-B', 'domain-A';
            $ruleResult.Length | Should -Be 3;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'topic-C', 'domain-B';
            $ruleResult.Length | Should -Be 2;
        }

        It 'Azure.EventGrid.TopicTLS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventGrid.TopicTLS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'topic-A', 'topic-B';
            $ruleResult.Length | Should -Be 2;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'topic-C';
            $ruleResult.Length | Should -Be 1;
        }

        It 'Azure.EventGrid.DomainTLS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventGrid.DomainTLS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'domain-A';
            $ruleResult.Length | Should -Be 1;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'domain-B';
            $ruleResult.Length | Should -Be 1;
        }

        It 'Azure.EventGrid.NamespaceTLS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventGrid.NamespaceTLS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'namespace-B';
            $ruleResult.Length | Should -Be 1;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'namespace-A';
            $ruleResult.Length | Should -Be 1;
        }
    }

    Context 'With Template' {
        BeforeAll {
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.EventGrid.json;
            Get-AzRuleTemplateLink -Path $here -InputPath 'Resources.EventGrid.Parameters.json' | Export-AzRuleTemplateData  -OutputPath $outputFile;
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $result = Invoke-PSRule @invokeParams -InputPath $outputFile -Outcome All;
        }

        It 'Azure.EventGrid.TopicPublicAccess' {
            $filteredResult = $result | Where-Object {
                $_.RuleName -eq 'Azure.EventGrid.TopicPublicAccess' -and
                $_.TargetType -eq 'Microsoft.EventGrid/topics'
            };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'topic-001', 'topic-002';
        }

        It 'Azure.EventGrid.ManagedIdentity' {
            $filteredResult = $result | Where-Object {
                $_.RuleName -eq 'Azure.EventGrid.ManagedIdentity' -and
                $_.TargetType -eq 'Microsoft.EventGrid/topics'
            };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'topic-001', 'topic-002';
        }

        It 'Azure.EventGrid.DisableLocalAuth' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventGrid.DisableLocalAuth' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'topic-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'topic-002';
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

            $option = New-PSRuleOption -Configuration @{
                'AZURE_EVENTGRID_DOMAIN_NAME_FORMAT' = '^evgd-'
                'AZURE_EVENTGRID_SYSTEM_TOPIC_NAME_FORMAT' = '^egst-'
                'AZURE_EVENTGRID_CUSTOM_TOPIC_NAME_FORMAT' = '^evgt-'
            };

            $names = @(
                'evgd-'
                'evgt-'
                'egst-'
                'topic-1'
                'EVGD-'
                'EVGT-'
                'EVST-'
            )

            $items = @($names | ForEach-Object {
                [PSCustomObject]@{
                    Name         = $_
                    Type = 'Microsoft.EventGrid/domains'
                }

                [PSCustomObject]@{
                    Name         = $_
                    Type = 'Microsoft.EventGrid/topics'
                }

                [PSCustomObject]@{
                    Name         = $_
                    Type = 'Microsoft.EventGrid/systemTopics'
                }
            })

            $result = $items | Invoke-PSRule @invokeParams -Option $option -Name 'Azure.EventGrid.DomainNaming', 'Azure.EventGrid.TopicNaming', 'Azure.EventGrid.SystemTopicNaming'
        }

        It 'Azure.EventGrid.DomainNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventGrid.DomainNaming' };
            $validNames = @(
                'evgd-'
            )

            $invalidNames = @(
                'evgt-'
                'egst-'
                'topic-1'
                'EVGD-'
                'EVGT-'
                'EVST-'
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

        It 'Azure.EventGrid.TopicNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventGrid.TopicNaming' };
            $validNames = @(
                'evgt-'
            )

            $invalidNames = @(
                'evgd-'
                'egst-'
                'topic-1'
                'EVGD-'
                'EVGT-'
                'EVST-'
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

        It 'Azure.EventGrid.SystemTopicNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.EventGrid.SystemTopicNaming' };
            $validNames = @(
                'egst-'
            )

            $invalidNames = @(
                'evgd-'
                'evgt-'
                'topic-1'
                'EVGD-'
                'EVGT-'
                'EVST-'
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
