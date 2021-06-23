# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Application Insights rules
#

[CmdletBinding()]
param ()

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

Describe 'Azure.AppInsights' -Tag 'AppInsights' {
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.AppInsights.json';

    Context 'Conditions' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $result = Invoke-PSRule @invokeParams -InputPath $dataPath;

        It 'Azure.AppInsights.Workspace' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppInsights.Workspace' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'insights-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'insights-A';
        }
    }

    Context 'With Template' {
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

    Context 'Resource name - Azure.AppInsights.Name' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $validNames = @(
            'app-1'
            '1-App'
            'app_1'
            'app.1'
            'app(1)'
            '..app1'
            '--app1'
            '__app1'
        )
        $invalidNames = @(
            'app1.'
            'app[1]'
            'app1?'
        )
        $testObject = [PSCustomObject]@{
            Name = ''
            ResourceType = 'microsoft.insights/components'
        }

        # Pass
        foreach ($name in $validNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.AppInsights.Name';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Pass';
            }
        }

        # Fail
        foreach ($name in $invalidNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.AppInsights.Name';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Fail';
            }
        }
    }
}
