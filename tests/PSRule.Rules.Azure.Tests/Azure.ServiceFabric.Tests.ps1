# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Service Fabric rules
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

Describe 'Azure.ServiceFabric' -Tag 'ServiceFabric' {
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.ServiceFabric.json';

    Context 'Conditions' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;

        It 'Azure.ServiceFabric.AAD' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ServiceFabric.AAD' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-A';
        }
    }

    Context 'With template' {
        $templatePath = Join-Path -Path $here -ChildPath 'Resources.ServiceFabric.Template.json';
        $parameterPath = Join-Path -Path $here -ChildPath 'Resources.ServiceFabric.Parameters.json';
        $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.ServiceFabric.json;
        Export-AzRuleTemplateData -TemplateFile $templatePath -ParameterFile $parameterPath -OutputPath $outputFile;
        $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;

        It 'Azure.ServiceFabric.AAD' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ServiceFabric.AAD' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'cluster-001';
        }
    }
}
