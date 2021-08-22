# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure template and parameter files
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

Describe 'Azure.Template' -Tag 'Template' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'SilentlyContinue'
                ErrorAction = 'Stop'
            }
        }

        It 'Azure.Template.TemplateFile' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Template*.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.TemplateFile';
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
            ($ruleResult | Where-Object { $_.TargetName -like "*Resources.Template.json" }).TargetName | Should -BeLike "*Resources.Template.json";
            ($ruleResult | Where-Object { $_.TargetName -like "*Resources.Template4.json" }).TargetName | Should -BeLike "*Resources.Template4.json";
        }

        It 'Azure.Template.TemplateSchema' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Template*.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.TemplateSchema';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.TemplateSchema' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName.Replace('\', '/').Split('/')[-1] | Should -BeIn 'Resources.Template.json', 'Resources.Template3.json';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName.Replace('\', '/').Split('/')[-1] | Should -BeIn 'Resources.Template2.json', 'Resources.Template4.json';
        }

        It 'Azure.Template.TemplateScheme' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Template*.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.TemplateScheme';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.TemplateScheme' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName.Replace('\', '/').Split('/')[-1] | Should -BeIn 'Resources.Template2.json';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName.Replace('\', '/').Split('/')[-1] | Should -BeIn @(
                'Resources.Template.json'
                'Resources.Template3.json'
                'Resources.Template4.json'
            );
        }

        It 'Azure.Template.ParameterMetadata' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Template*.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.ParameterMetadata';
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

        It 'Azure.Template.DefineParameters' {
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.json')
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.2.json')
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.3.json')
                (Join-Path -Path $here -ChildPath 'Template.Bicep.1.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.DefineParameters';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.DefineParameters' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Empty.Template.2.json', 'Resources.Empty.Template.3.json';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Empty.Template.json';
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
                (Join-Path -Path $here -ChildPath 'Resources.TTK.Template.2.json')
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
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Template4.json', 'Resources.TTK.Template.2.json';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Template3.json';
        }

        It 'Azure.Template.LocationType' {
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.json')
                (Join-Path -Path $here -ChildPath 'Resources.TTK.Template.1.json')
                (Join-Path -Path $here -ChildPath 'Resources.Template3.json')
                (Join-Path -Path $here -ChildPath 'Resources.Template4.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All -Format None -Name 'Azure.Template.LocationType';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.LocationType' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.TTK.Template.1.json';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Template4.json', 'Resources.Empty.Template.json';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Template3.json';
        }

        It 'Azure.Template.ResourceLocation' {
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.json')
                (Join-Path -Path $here -ChildPath 'Resources.TTK.Template.2.json')
                (Join-Path -Path $here -ChildPath 'Resources.TTK.Template.3.json')
                (Join-Path -Path $here -ChildPath 'Resources.TTK.Template.4.json')
                (Join-Path -Path $here -ChildPath 'Resources.Template4.json')
                (Join-Path -Path $here -ChildPath 'Resources.KeyVault.Template.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All -Format None -Name 'Azure.Template.ResourceLocation';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.ResourceLocation' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.TTK.Template.2.json', 'Resources.TTK.Template.3.json', 'Resources.TTK.Template.4.json';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Template4.json', 'Resources.KeyVault.Template.json';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Empty.Template.json';
        }

        It 'Azure.Template.UseLocationParameter' {
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.json')
                (Join-Path -Path $here -ChildPath 'Resources.TTK.Template.1.json')
                (Join-Path -Path $here -ChildPath 'Resources.TTK.Template.2.json')
                (Join-Path -Path $here -ChildPath 'Resources.Template4.json')
                (Join-Path -Path $here -ChildPath 'Template.Bicep.1.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All -Format None -Name 'Azure.Template.UseLocationParameter';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.UseLocationParameter' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.TTK.Template.1.json';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Template4.json', 'Resources.Empty.Template.json', 'Resources.TTK.Template.2.json';
        }

        It 'Azure.Template.ParameterMinMaxValue' {
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Resources.TTK.Template.1.json')
                (Join-Path -Path $here -ChildPath 'Resources.TTK.Template.2.json')
                (Join-Path -Path $here -ChildPath 'Resources.TTK.Template.3.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All -Format None -Name 'Azure.Template.ParameterMinMaxValue';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.ParameterMinMaxValue' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.TTK.Template.1.json', 'Resources.TTK.Template.2.json';
            $ruleResult[0].Reason.Length | Should -Be 1;
            $ruleResult[0].Reason[0] | Should -BeLike "The field 'type' is set to '*'.";
            $ruleResult[1].Reason.Length | Should -Be 2;
            $ruleResult[1].Reason[0] | Should -BeLike "The minValue for 'valueInt' is not int.";
            $ruleResult[1].Reason[1] | Should -BeLike "The maxValue for 'valueInt' is not int.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.TTK.Template.3.json';
        }

        It 'Azure.Template.DebugDeployment' {
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Resources.TTK.Template.1.json')
                (Join-Path -Path $here -ChildPath 'Resources.TTK.Template.3.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All -Format None -Name 'Azure.Template.DebugDeployment';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.DebugDeployment' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.TTK.Template.3.json';
            $ruleResult[0].Reason.Length | Should -Be 1;
            $ruleResult[0].Reason | Should -Be "The field 'properties.debugSetting.detailLevel' is set to 'requestContent'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.TTK.Template.1.json';
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
            $ruleResult[0].Reason[0] | Should -BeLike "The defaultValue for 'notStringParam' is not string.";
            $ruleResult[0].Reason[1] | Should -BeLike "The defaultValue for 'notBoolParam' is not bool.";
            $ruleResult[0].Reason[2] | Should -BeLike "The defaultValue for 'notArrayParam' is not array.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Template3.json', 'Resources.Template4.json';
        }

        It 'Azure.Template.ParameterFile' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Parameters*.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.ParameterFile';
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

        It 'Azure.Template.ParameterScheme' {
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.Parameters*.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.ParameterScheme';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.ParameterScheme' };

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

        It 'Azure.Template.MetadataLink' {
            $dataPath = Join-Path -Path $here -ChildPath '*.Parameters.json';
            $options = @{
                'Configuration.AZURE_PARAMETER_FILE_METADATA_LINK' = $True
            }
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $options -Format File -Name 'Azure.Template.MetadataLink';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.MetadataLink' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'tests/PSRule.Rules.Azure.Tests/Resources.ServiceFabric.Parameters.json';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
        }

        It 'Azure.Template.ParameterValue' {
            $dataPath = @(
                Join-Path -Path $here -ChildPath 'Resources.Parameters.json'
                Join-Path -Path $here -ChildPath 'Resources.VPN.Parameters2.json'
                Join-Path -Path $here -ChildPath 'Resources.ParameterFile.Fail5.json'
            )
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.ParameterValue';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.ParameterValue' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.ParameterFile.Fail5.json';
            $ruleResult[0].Reason | Should -Be 'The parameter ''vnetName'' must have a value or Key Vault reference set.';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Parameters.json', 'Resources.VPN.Parameters2.json';
        }

        It 'Azure.Template.ValidSecretRef' {
            $dataPath = @(
                Join-Path -Path $here -ChildPath 'Resources.Parameters.json'
                Join-Path -Path $here -ChildPath 'Resources.VPN.Parameters2.json'
                Join-Path -Path $here -ChildPath 'Resources.VPN.Parameters3.json'
            )
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.ValidSecretRef';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.ValidSecretRef' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.VPN.Parameters2.json';
            $ruleResult[0].Reason[0] | Should -Be 'The field ''reference.keyVault.id'' does not exist.';
            $ruleResult[0].Reason[1] | Should -Be 'The field value ''not_a_secret'' does not match the pattern ''^[A-Za-z0-9-]{1,127}$''.';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Parameters.json', 'Resources.VPN.Parameters3.json';
        }
    }
}
