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
            $templatePath = Join-Path -Path $here -ChildPath 'Resources.Deployments.json';
            $parameterPath = Join-Path -Path $here -ChildPath 'Resources.Parameters.json';
            $result = Invoke-PSRule @invokeParams -TemplateFile $templatePath -ParameterFile $parameterPath -Outcome All;
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
             $ruleResult.Length | Should -Be 4;
             $ruleResult.TargetName | Should -BeIn 'nestedDeployment-B', 'nestedDeployment-C', 'nestedDeployment-F', 'nestedDeployment-G';
        }

        Context 'With Template' {
            BeforeAll {
                $templatePath = Join-Path -Path $here -ChildPath 'Resources.Deployments.Template.json';
                $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.Deployments.Template.json;
                Export-AzRuleTemplateData -TemplateFile $templatePath -OutputPath $outputFile;
                $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;
            }
        
            It 'Azure.Deployment.OuterSecret' {
                $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Deployment.OuterSecret' };
        
                 # Fail
                 $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
                 $ruleResult | Should -Not -BeNullOrEmpty;
                 $ruleResult.Length | Should -Be 2;
                 $ruleResult.TargetName | Should -BeIn 'nestedDeployment-D', 'nestedDeployment-E';
        
                 # Pass
                 $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
                 $ruleResult | Should -Not -BeNullOrEmpty;
                 $ruleResult.Length | Should -Be 3;
                 $ruleResult.TargetName | Should -BeIn 'nestedDeployment-A', 'nestedDeployment-B', 'nestedDeployment-C';
            }
        
        }

        
    }
}



