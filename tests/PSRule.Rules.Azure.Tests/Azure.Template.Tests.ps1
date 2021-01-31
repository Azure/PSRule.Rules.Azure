# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure template and parameter files
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

Describe 'Azure.Template' -Tag 'Template' {
    Context 'Conditions' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'SilentlyContinue'
            ErrorAction = 'Stop'
        }

        It 'Azure.Template.TemplateFile' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Template*.json';
            $result = Get-Item -Path $dataPath | Invoke-PSRule @invokeParams -Name 'Azure.Template.TemplateFile';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.TemplateFile' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeLike "*Resources.Template[2-3].json";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult[0].TargetName | Should -BeLike "*Resources.Template.json";
            $ruleResult[1].TargetName | Should -BeLike "*Resources.Template4.json";
        }

        It 'Azure.Template.ParameterMetadata' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Template*.json';
            $result = Get-Item -Path $dataPath | Invoke-PSRule @invokeParams -Name 'Azure.Template.ParameterMetadata';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.ParameterMetadata' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeLike "*Resources.Template[3-4].json";

            # With empty template
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.2.json')
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.3.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.ParameterMetadata';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.ParameterMetadata' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
        }

        It 'Azure.Template.Resources' {
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.json')
                (Join-Path -Path $here -ChildPath 'Resources.Template3.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.Resources';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.Resources' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeLike "*Resources.Empty.Template.json";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeLike "*Resources.Template3.json";
        }

        It 'Azure.Template.UseParameters' {
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.json')
                (Join-Path -Path $here -ChildPath 'Resources.Template3.json')
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.2.json')
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.3.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.UseParameters';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.UseParameters' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeLike "*Resources.Empty.Template.json";
            $ruleResult.Reason | Should -BeLike "The parameter '*' was not used within the template.";
            $ruleResult.Reason.Length | Should -Be 11;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
        }

        It 'Azure.Template.UseVariables' {
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.json')
                (Join-Path -Path $here -ChildPath 'Resources.Template3.json')
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.2.json')
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.3.json')
                (Join-Path -Path $here -ChildPath 'Resources.Copy.Template.1.json')
                (Join-Path -Path $here -ChildPath 'Resources.Copy.Template.2.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.UseVariables';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.UseVariables' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Empty.Template.json', 'Resources.Copy.Template.2.json';
            $ruleResult[0].Reason | Should -BeLike "The variable '*' was not used within the template.";
            $ruleResult[0].Reason.Length | Should -Be 2;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
        }

        It 'Azure.Template.LocationDefault' {
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.json')
                (Join-Path -Path $here -ChildPath 'Resources.Template3.json')
                (Join-Path -Path $here -ChildPath 'Resources.Template4.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All -Format None -Name 'Azure.Template.LocationDefault';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.LocationDefault' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Empty.Template.json';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Template4.json';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Template3.json';
        }

        It 'Azure.Template.ParameterDataTypes' {
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.json')
                (Join-Path -Path $here -ChildPath 'Resources.Template3.json')
                (Join-Path -Path $here -ChildPath 'Resources.Template4.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All -Format None -Name 'Azure.Template.ParameterDataTypes';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.ParameterDataTypes' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Empty.Template.json';
            $ruleResult[0].Reason.Length | Should -Be 3;
            $ruleResult[0].Reason[0] | Should -BeLike "The default value for 'notStringParam' is not string.";
            $ruleResult[0].Reason[1] | Should -BeLike "The default value for 'notBoolParam' is not bool.";
            $ruleResult[0].Reason[2] | Should -BeLike "The default value for 'notArrayParam' is not array.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Template3.json', 'Resources.Template4.json';
        }

        It 'Azure.Template.ParameterFile' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Parameters*.json';
            $result = Get-Item -Path $dataPath | Invoke-PSRule @invokeParams -Name 'Azure.Template.ParameterFile';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.ParameterFile' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeLike "*Resources.Parameters2.json";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeLike "*Resources.Parameters.json";
        }
    }
}
