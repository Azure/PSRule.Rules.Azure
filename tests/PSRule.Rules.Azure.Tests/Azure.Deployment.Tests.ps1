# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure deployments
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

Describe 'Azure.Deployment' -Tag 'Deployment' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'SilentlyContinue'
                ErrorAction = 'Stop'
            }
        }

        It 'Azure.Deployment.OutputSecretValue' {
            $sourcePath = Join-Path -Path $here -ChildPath 'Tests.Bicep.7.json';
            $data = Export-AzRuleTemplateData -TemplateFile $sourcePath -PassThru;
            $result = $data | Invoke-PSRule @invokeParams -Name 'Azure.Deployment.OutputSecretValue';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Deployment.OutputSecretValue' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetObject.name };
            $targetNames | Should -BeIn 'ps-rule-test-deployment', 'child';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetObject.name };
            $targetNames | Should -BeIn 'good';
        }

        It 'Azure.Deployment.SecureValue' {
            $sourcePath = Join-Path -Path $here -ChildPath 'Tests.Bicep.9.json';
            $data = Export-AzRuleTemplateData -TemplateFile $sourcePath -PassThru;
            $result = $data | Invoke-PSRule @invokeParams -Name 'Azure.Deployment.SecureValue';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Deployment.SecureValue' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            # $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetObject.name };
            $targetNames | Should -BeIn 'secret_bad', 'ps-rule-test-deployment';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetObject.name };
            $targetNames | Should -BeIn 'secret_good';
        }
    }
}


Describe 'Azure.Deployment.AdminUsername' -Tag 'Deployment' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Deployments.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.Deployment.AdminUsername' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Deployment.AdminUsername' };

             # Fail
             $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
             $ruleResult | Should -Not -BeNullOrEmpty;
             $ruleResult.Length | Should -Be 3;
             $ruleResult.TargetName | Should -BeIn 'nestedDeployment-A', 'nestedDeployment-D', 'nestedDeployment-E';
 
             # Pass
             $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
             $ruleResult | Should -Not -BeNullOrEmpty;
             $ruleResult.Length | Should -Be 5;
             $ruleResult.TargetName | Should -BeIn 'nestedDeployment-B', 'nestedDeployment-C', 'nestedDeployment-F', 'nestedDeployment-G', 'nestedDeployment-H';
        }
    }

    Context 'With Template' {
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'deployment.tests.json';
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.Deployment.json;
            Export-AzRuleTemplateData -TemplateFile $templatePath -OutputPath $outputFile;
            $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;
        }

        It 'Azure.Deployment.AdminUsername' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Deployment.AdminUsername' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
        }
    }
}
