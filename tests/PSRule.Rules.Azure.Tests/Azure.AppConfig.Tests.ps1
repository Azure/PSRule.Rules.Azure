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
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'app-config-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'Sku.name';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'app-config-A';
        }

        It 'Azure.AppConfig.DisableLocalAuth' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppConfig.DisableLocalAuth' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'app-config-B';
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
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'app-config-A', 'app-config-C', 'app-config-D', 'app-config-E', 'app-config-F', 'app-config-G', 'app-config-H';

            $ruleResult[0].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (app-config-A-diagnostic) should enable (Audit) or category group (audit, allLogs).";
            $ruleResult[1].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (app-config-C-diagnostic) should enable (Audit) or category group (audit, allLogs).";
            $ruleResult[2].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (app-config-D-diagnostic) should enable (Audit) or category group (audit, allLogs).";
            $ruleResult[3].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (app-config-E-diagnostic) should enable (Audit) or category group (audit, allLogs).";
            $ruleResult[4].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (app-config-F-diagnostic) should enable (Audit) or category group (audit, allLogs).";
            $ruleResult[5].Reason | Should -BeExactly "Path resources[0].properties.logs: The diagnostic setting (app-config-G-diagnostic) should enable (Audit) or category group (audit, allLogs).";
            $ruleResult[5].Reason | Should -BeExactly "Diagnostic settings are not configured.";


            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'app-config-B', 'app-config-I';
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
