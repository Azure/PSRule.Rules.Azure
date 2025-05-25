# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Application Insights rules
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

Describe 'Azure.AppInsights' -Tag 'AppInsights' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.AppInsights.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.AppInsights.Workspace' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppInsights.Workspace' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'insights-B';
            $ruleResult.Length | Should -Be 1;
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.workspaceResourceId';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'insights-A';
            $ruleResult.Length | Should -Be 1;
        }

        It 'Azure.AppInsights.LocalAuth' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppInsights.LocalAuth' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -Be 'insights-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.disableLocalAuth';
            $ruleResult.Length | Should -Be 1;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -Be 'insights-A';
            $ruleResult.Length | Should -Be 1;
        }
    }

    Context 'With Template' {
        BeforeAll {
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.AppInsights.json;
            $templatePath = Join-Path -Path $here -ChildPath 'Resources.AppInsights.Template.json';
            Export-AzRuleTemplateData -TemplateFile $templatePath -OutputPath $outputFile;
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $result = Invoke-PSRule @invokeParams -InputPath $outputFile -Outcome All;
        }

        It 'Azure.AppInsights.Workspace' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppInsights.Workspace' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'appinsights001';
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

            $option = New-PSRuleOption -Configuration @{ 'AZURE_APP_INSIGHTS_NAME_FORMAT' = '^appi-' };

            $names = @(
                'app-1'
                '1-App'
                'app_1'
                'app.1'
                'app(1)'
                '..app1'
                '--app1'
                '__app1'
                'app1.'
                'app[1]'
                'app1?'
                'appi-001'
            )

            $items = @($names | ForEach-Object {
                [PSCustomObject]@{
                    Name         = $_
                    Type = 'Microsoft.Insights/components'
                }
            })

            $result = $items | Invoke-PSRule @invokeParams -Option $option -Name 'Azure.AppInsights.Name','Azure.AppInsights.Naming'
        }

        It 'Azure.AppInsights.Name' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppInsights.Name' };
            $validNames = @(
                'app-1'
                '1-App'
                'app_1'
                'app.1'
                'app(1)'
                '..app1'
                '--app1'
                '__app1'
                'appi-001'
            )

            $invalidNames = @(
                'app1.'
                'app[1]'
                'app1?'
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

        It 'Azure.AppInsights.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppInsights.Naming' };
            $validNames = @(
                'appi-001'
            )

            $invalidNames = @(
                'app-1'
                '1-App'
                'app_1'
                'app.1'
                'app(1)'
                '..app1'
                '--app1'
                '__app1'
                'app1.'
                'app[1]'
                'app1?'
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
