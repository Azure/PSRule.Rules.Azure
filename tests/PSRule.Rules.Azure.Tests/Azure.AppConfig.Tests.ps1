# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure App Configuration rules
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

Describe 'Azure.AppConfig' -Tag 'AppConfig' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.AppConfig.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.AppConfig.SKU' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppConfig.SKU' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -Be 'app-config-B', 'app-config-C', 'app-config-D', 'app-config-E', 'app-config-G';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'Sku.name';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'app-config-A', 'app-config-F', 'app-config-H', 'app-config-I';
        }

        It 'Azure.AppConfig.DisableLocalAuth' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppConfig.DisableLocalAuth' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -Be 'app-config-B', 'app-config-C', 'app-config-D', 'app-config-E', 'app-config-F', 'app-config-G', 'app-config-H', 'app-config-I';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'Properties.disableLocalAuth';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'app-config-A';
        }

        It 'Azure.AppConfig.AuditLogs' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.AppConfig.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppConfig.AuditLogs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'app-config-A', 'app-config-C', 'app-config-E', 'app-config-G', 'app-config-H';

            $ruleResult[0].Reason | Should -BeExactly "Path resources.properties.logs: Minimum one diagnostic setting should have (Audit) configured or category group (audit, allLogs) configured.";
            $ruleResult[1].Reason | Should -BeExactly "Path resources.properties.logs: Minimum one diagnostic setting should have (Audit) configured or category group (audit, allLogs) configured.";
            $ruleResult[2].Reason | Should -BeExactly "Path resources.properties.logs: Minimum one diagnostic setting should have (Audit) configured or category group (audit, allLogs) configured.";
            $ruleResult[3].Reason | Should -BeExactly "Path resources.properties.logs: Minimum one diagnostic setting should have (Audit) configured or category group (audit, allLogs) configured.";
            $ruleResult[4].Reason | Should -BeExactly "Path resources.properties.logs: Minimum one diagnostic setting should have (Audit) configured or category group (audit, allLogs) configured.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'app-config-B', 'app-config-D', 'app-config-F', 'app-config-I';
        }

        It 'Azure.AppConfig.GeoReplica' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.AppConfig.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppConfig.GeoReplica' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'app-config-A', 'app-config-F', 'app-config-H';

            $ruleResult[0].Reason | Should -BeExactly "A replica in a secondary region was not found.";
            $ruleResult[1].Reason | Should -BeExactly "A replica in a secondary region was not found.";
            $ruleResult[2].Reason | Should -BeExactly "A replica in a secondary region was not found.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'app-config-I';
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
                ResourceType = 'Microsoft.AppConfiguration/configurationStores'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'config-1'
                '1-Config'
            )
            $invalidNames = @(
                'config_1'
                'cfg1'
                'config.1'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.AppConfig.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.AppConfig.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'name';
        }
    }
}
