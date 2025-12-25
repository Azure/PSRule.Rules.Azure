# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Automation Rules
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

Describe 'Azure.Automation' -Tag Automation {
    Context 'Conditions' {
        BeforeAll {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Automation.json';
            $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $dataPath -WarningAction Ignore -ErrorAction Stop;
        }

        It 'Azure.Automation.EncryptVariables' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Automation.EncryptVariables' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'automation-b';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'resources[0].properties.isEncrypted';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -Be 'automation-a', 'automation-c', 'automation-d', 'automation-e', 'automation-f', 'automation-g';
        }

        It 'Azure.Automation.WebHookExpiry' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Automation.WebHookExpiry' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;

            # NOTE: It is expected that `automation-b/webhook-a` no longer fails late in December each
            # year due to the expiry time being less then a year away.
            # When this happens, tests will fail and this needs to be bumped a year.
            $ruleResult.TargetName | Should -Be 'automation-a', 'automation-b';
            # TODO: $ruleResult.Detail.Reason.Path | Should -BeIn 'resources[1].properties.expiryTime';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -Be 'automation-c', 'automation-d', 'automation-e', 'automation-f', 'automation-g';
        }

        It 'Azure.Automation.ManagedIdentity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Automation.ManagedIdentity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'automation-a', 'automation-b', 'automation-c';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'identity.type';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'automation-d', 'automation-e', 'automation-f', 'automation-g';
        }

        It 'Azure.Automation.AuditLogs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Automation.AuditLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'automation-e', 'automation-f', 'automation-g';

            $ruleResult[0].Reason | Should -BeExactly "Minimum one diagnostic setting should have (AuditEvent) configured or category group (audit, allLogs) configured.";
            $ruleResult[1].Reason | Should -BeExactly "Minimum one diagnostic setting should have (AuditEvent) configured or category group (audit, allLogs) configured.";
            $ruleResult[2].Reason | Should -BeExactly "Minimum one diagnostic setting should have (AuditEvent) configured or category group (audit, allLogs) configured.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'automation-a', 'automation-b', 'automation-c', 'automation-d';
        }

        It 'Azure.Automation.PlatformLogs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Automation.PlatformLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'automation-b', 'automation-c', 'automation-f', 'automation-g';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'resources[0].properties.logs', 'resources[2].properties.logs';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Path resources[2].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, JobStreams, DscNodeStatus, AllMetrics) or category group (allLogs).";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, JobStreams, DscNodeStatus, AllMetrics) or category group (allLogs).";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, JobStreams, DscNodeStatus, AllMetrics) or category group (allLogs).";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, JobStreams, DscNodeStatus, AllMetrics) or category group (allLogs).";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'automation-a', 'automation-d', 'automation-e';
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
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Automation.json';
            $configPath = Join-Path -Path $here -ChildPath 'ps-rule-options.yaml';
        }

        It 'Azure.Automation.PlatformLogs - HashTable option - Excluding metrics category' {
            $option = @{
                'Configuration.AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST' = @(
                    'JobLogs',
                    'JobStreams',
                    'DscNodeStatus'
                )
            }

            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $option
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Automation.PlatformLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'automation-b', 'automation-c', 'automation-f', 'automation-g';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Path resources[2].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, JobStreams, DscNodeStatus) or category group (allLogs).";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, JobStreams, DscNodeStatus) or category group (allLogs).";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, JobStreams, DscNodeStatus) or category group (allLogs).";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, JobStreams, DscNodeStatus) or category group (allLogs).";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'automation-a', 'automation-d', 'automation-e';
        }

        It 'Azure.Automation.PlatformLogs - HashTable option - Excluding log category' {
            $option = @{
                'Configuration.AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST' = @(
                    'JobLogs',
                    'JobStreams',
                    'AllMetrics'
                )
            }

            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $option
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Automation.PlatformLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'automation-b', 'automation-c', 'automation-f';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Path resources[2].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, JobStreams, AllMetrics) or category group (allLogs).";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, JobStreams, AllMetrics) or category group (allLogs).";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, JobStreams, AllMetrics) or category group (allLogs).";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'automation-a', 'automation-d', 'automation-e', 'automation-g';
        }

        It 'Azure.Automation.PlatformLogs - HashTable option - Excluding log and metrics category' {
            $option = @{
                'Configuration.AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST' = @(
                    'JobLogs',
                    'JobStreams'
                )
            }

            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $option
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Automation.PlatformLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'automation-b', 'automation-c', 'automation-f';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Path resources[2].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, JobStreams) or category group (allLogs).";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, JobStreams) or category group (allLogs).";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, JobStreams) or category group (allLogs).";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'automation-a', 'automation-d', 'automation-e', 'automation-g';
        }

        It 'Azure.Automation.PlatformLogs - YAML file option - Excluding log categories' {
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $configPath
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Automation.PlatformLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'automation-b', 'automation-c';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Path resources[2].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, AllMetrics) or category group (allLogs).";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (metrics) should enable (JobLogs, AllMetrics) or category group (allLogs)."

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -Be 'automation-a', 'automation-d', 'automation-e', 'automation-f', 'automation-g';
        }

    }
}
