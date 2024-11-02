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
            $ruleResult.Length | Should -Be 4;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetObject.name };
            $targetNames | Should -BeIn 'secret_bad', 'ps-rule-test-deployment', 'streaming_jobs_bad', 'container_apps_bad';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetObject.name };
            $targetNames | Should -BeIn 'secret_good', 'streaming_jobs_good', 'reference_good';
        }
    }

    Context 'With Template' {
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'deployment.tests.json';
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.Deployment.json;
            Export-AzRuleTemplateData -TemplateFile $templatePath -OutputPath $outputFile;
            $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;
        }

        It 'Azure.Deployment.Name' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Deployment.Name' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
        }
    }
}

Describe 'Azure.Deployment' -Tag 'Deployment' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'SilentlyContinue'
                ErrorAction = 'Stop'
                Option = @{
                    'Configuration.AZURE_DEPLOYMENT_NONSENSITIVE_PARAMETER_NAMES' = @('notSecret')
                }
            }
        }

        It 'Azure.Deployment.SecureParameter' {
            $sourcePath = Join-Path -Path $here -ChildPath 'Resources.Deployments.json';
            $result = Invoke-PSRule @invokeParams -InputPath $sourcePath -Name 'Azure.Deployment.SecureParameter';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Deployment.SecureParameter' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'nestedDeployment-I';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -BeIn 'nestedDeployment-A', 'nestedDeployment-B', 'nestedDeployment-C', 'nestedDeployment-D', 'nestedDeployment-E', 'nestedDeployment-F', 'nestedDeployment-G', 'nestedDeployment-H', 'nestedDeployment-J';
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
             $ruleResult.Length | Should -Be 7;
             $ruleResult.TargetName | Should -BeIn 'nestedDeployment-B', 'nestedDeployment-C', 'nestedDeployment-F', 'nestedDeployment-G', 'nestedDeployment-H', 'nestedDeployment-I', 'nestedDeployment-J';
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

    Context 'With Bicep with symbolic names' {
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'Bicep/SymbolicNameTestCases/Tests.Bicep.5.json';
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
            $ruleResult.Length | Should -Be 10;
        }
    }
}

Describe 'Azure.Deployment.OuterSecret' -Tag 'Deployment' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            
        }

        Context 'With Template' {
            BeforeAll {
                $failTemplatePath = Join-Path -Path $here -ChildPath 'Resources.Deployments.Template.2.json';
                $failParameterPath = Join-Path -Path $here -ChildPath 'Resources.Deployments.Parameters.2.json';
                $passTemplatePath = Join-Path -Path $here -ChildPath 'Resources.Deployments.Template.1.json';
                $passParameterPath = Join-Path -Path $here -ChildPath 'Resources.Deployments.Parameters.1.json';
                $passOutputFile = Join-Path -Path $rootPath -ChildPath 'out/tests/Resources.Deployments.Template.1.json';
                $failOutputFile = Join-Path -Path $rootPath -ChildPath 'out/tests/Resources.Deployments.Template.2.json';
                Export-AzRuleTemplateData -TemplateFile $failTemplatePath -ParameterFile $failParameterPath -OutputPath $failOutputFile;
                Export-AzRuleTemplateData -TemplateFile $passTemplatePath -ParameterFile $passParameterPath -OutputPath $passOutputFile;
                $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $passOutputFile,$failOutputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;
            }

            It 'Azure.Deployment.OuterSecret' {
                $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Deployment.OuterSecret' };
            
                 # Fail
                 $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
                 $ruleResult | Should -Not -BeNullOrEmpty;
                 $ruleResult.Length | Should -Be 1;
                 $ruleResult.TargetName | Should -Be $failParameterPath
            
                 # Pass
                 $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
                 $ruleResult | Should -Not -BeNullOrEmpty;
                 $ruleResult.Length | Should -Be 1;
                 $ruleResult.TargetName | Should -Be $passParameterPath;
            }
        }
    }

}

Context 'Resource name - Azure.Deployment.Name' {
    BeforeAll {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }

        $testObject = [PSCustomObject]@{
            Name = ''
            ResourceType = 'Microsoft.Resources/deployments'
        }
    }

    BeforeDiscovery {
        $validNames = @(
            'nestedtemplate'
            'nestedtemplate1'
            'nestedtemplate-1'
            'NESTEDTEMPLATE'
            'nestedtemplate(1)'
            'nested.Template1'
        )

        $invalidNames = @(
            'nestedtemplate!'
            '!NESTEDTEMPLATE'
            'nestedtemplate?'
            'nestedtemplate!!NESTEDTEMPLATE'
            'nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnestedtemplateeeeeeeeee'
        )
    }

    # Pass
    It '<_>' -ForEach $validNames {
        $testObject.Name = $_;
        $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.Deployment.Name';
        $ruleResult | Should -Not -BeNullOrEmpty;
        $ruleResult.Outcome | Should -Be 'Pass';
    }

    # Fail
    It '<_>' -ForEach $invalidNames {
        $testObject.Name = $_;
        $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.Deployment.Name';
        $ruleResult | Should -Not -BeNullOrEmpty;
        $ruleResult.Outcome | Should -Be 'Fail';
    }
}
