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
            $ruleResult.Length | Should -Be 5;
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
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName.Replace('\', '/').Split('/')[-1] | Should -BeIn 'Resources.Template2.json', 'Resources.Template4.json', 'Resources.Template.Bicep1.json', 'Resources.Template.Bicep2.json', 'Resources.Template.V2.json';
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
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName.Replace('\', '/').Split('/')[-1] | Should -BeIn @(
                'Resources.Template.Bicep1.json'
                'Resources.Template.Bicep2.json'
                'Resources.Template.json'
                'Resources.Template.V2.json'
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

            $ruleResult0 = $ruleResult | Where-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] -eq 'Resources.Template.json' };
            $ruleResult0.Reason | Should -Not -BeNullOrEmpty;
            $ruleResult0.Reason | Should -HaveCount 6
            $ruleResult0.Reason | Should -Be @(
                "The parameter 'addressPrefix' does not have a description set.",
                "The parameter 'subnets' does not have a description set.",
                "The parameter 'aciSubnet' does not have a description set.",
                "The parameter 'clusterSubnet' does not have a description set.",
                "The parameter 'clusterObjectId' does not have a description set.",
                "The parameter 'delegate' does not have a description set."
            )
            $ruleResult1 = $ruleResult | Where-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] -eq 'Resources.Template2.json' };
            $ruleResult1.Reason | Should -Not -BeNullOrEmpty;
            $ruleResult1.Reason | Should -BeExactly "The parameter 'diagnosticStorageAccountName' does not have a description set.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName.Replace('\', '/').Split('/')[-1] | Should -BeIn @(
                'Resources.Template.Bicep1.json'
                'Resources.Template.Bicep2.json'
                'Resources.Template.V2.json'
                'Resources.Template3.json'
                'Resources.Template4.json'
            );

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

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -HaveCount 11;
            $ruleResult[0].Reason | Should -Be @(
                "The parameter 'customDomainName' was not used within the template.",
                "The parameter 'backendAddress' was not used within the template.",
                "The parameter 'diagnosticStorageAccountName' was not used within the template.",
                "The parameter 'location' was not used within the template.",
                "The parameter 'notStringParam' was not used within the template.",
                "The parameter 'notBoolParam' was not used within the template.",
                "The parameter 'intParam' was not used within the template.",
                "The parameter 'arrayParam' was not used within the template.",
                "The parameter 'arrayParamFn' was not used within the template.",
                "The parameter 'notArrayParam' was not used within the template.",
                "The parameter 'objectParam' was not used within the template."
            )

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
                (Join-Path -Path $here -ChildPath 'Template.PSArm.1.json')
                (Join-Path -Path $here -ChildPath 'Template.AzOps.1.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All -Format None -Name 'Azure.Template.DefineParameters';
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

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Template.Bicep.1.json', 'Template.PSArm.1.json', 'Template.AzOps.1.json';
        }

        It 'Azure.Template.UseVariables' {
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.json')
                (Join-Path -Path $here -ChildPath 'Resources.Template3.json')
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.2.json')
                (Join-Path -Path $here -ChildPath 'Resources.Empty.Template.3.json')
                (Join-Path -Path $here -ChildPath 'Resources.Copy.Template.1.json')
                (Join-Path -Path $here -ChildPath 'Resources.Copy.Template.2.json')
                (Join-Path -Path $here -ChildPath 'Tests.Bicep.6.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.UseVariables';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.UseVariables' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Empty.Template.json', 'Resources.Copy.Template.2.json';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -HaveCount 2;
            $ruleResult[0].Reason | Should -Be @(
                "The variable 'otherVariable' was not used within the template.",
                "The variable 'otherVariable2' was not used within the template."
            )
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The variable 'accounts' was not used within the template.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
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

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The default value for the parameter 'location' is 'eastus'.";

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
                (Join-Path -Path $here -ChildPath 'Template.PSArm.1.json')
                (Join-Path -Path $here -ChildPath 'Template.AzOps.1.json')
                (Join-Path -Path $here -ChildPath 'Resources.Policy.Template.json')
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All -Format None -Name 'Azure.Template.UseLocationParameter';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.UseLocationParameter' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.TTK.Template.1.json';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The expression 'resourceGroup().location' was found in the template.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Template4.json', 'Resources.Empty.Template.json', 'Resources.TTK.Template.2.json';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Template.Bicep.1.json', 'Template.PSArm.1.json', 'Template.AzOps.1.json', 'Resources.Policy.Template.json';
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

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -HaveCount 1;
            $ruleResult[0].Reason[0] | Should -BeExactly "Path type: Is set to 'array'.";
            $ruleResult[1].Reason | Should -HaveCount 2;
            $ruleResult[1].Reason | Should -Be @(
                "The minValue for 'valueInt' is not int.",
                "The maxValue for 'valueInt' is not int."
            )

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

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -HaveCount 3;
            $ruleResult[0].Reason | Should -Be @(
                "The defaultValue for 'notStringParam' is not string.",
                "The defaultValue for 'notBoolParam' is not bool.",
                "The defaultValue for 'notArrayParam' is not array."
            )

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Template3.json', 'Resources.Template4.json';
        }

        It 'Azure.Template.ParameterStrongType' {
            $dataPath = Join-Path -Path $here -ChildPath 'Template.StrongType.*.Parameters.json';
            $options = @{
                'Configuration.AZURE_PARAMETER_FILE_EXPANSION' = $True
            }
            $result = Invoke-PSRule @invokeParams -Option $options -InputPath $dataPath -Format File -Name 'Azure.Template.ParameterStrongType';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.ParameterStrongType' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Template.StrongType.1.Parameters.json', 'Template.StrongType.2.Parameters.json';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Template.StrongType.3.Parameters.json';
        }

        It 'Azure.Template.ExpressionLength' {
            $dataPath = @(
                (Join-Path -Path $here -ChildPath 'Template.Parsing.2.Parameters.json')
                (Join-Path -Path $here -ChildPath 'Template.Parsing.9.Parameters.json')
                (Join-Path -Path $here -ChildPath 'Template.Parsing.10.Parameters.json')
            );
            $options = @{
                'Configuration.AZURE_PARAMETER_FILE_EXPANSION' = $True
            }
            $result = Invoke-PSRule @invokeParams -Option $options -InputPath $dataPath -Format File -Name 'Azure.Template.ExpressionLength';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.ExpressionLength' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult[0].Reason.Length | Should -Be 1;
            $ruleResult[0].Reason | Should -BeLike 'The expression * is longer then the maximum length 24576.';
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Template.Parsing.9.Parameters.json';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Template.Parsing.2.Parameters.json', 'Template.Parsing.10.Parameters.json';
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
            $dataPath = @(
                (Join-Path -Path $here -ChildPath '*.Parameters.json')
                (Join-Path -Path $here -ChildPath '*.parameters.json')
                (Join-Path -Path $here -ChildPath '*.metalink.json')
            );
            $options = @{
                'Configuration.AZURE_PARAMETER_FILE_METADATA_LINK' = $True
            }
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $options -Format File -Name 'Azure.Template.MetadataLink';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.MetadataLink' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn @(
                'tests/PSRule.Rules.Azure.Tests/Tests.Bicep.1.Parameters.json'
                'tests/PSRule.Rules.Azure.Tests/Tests.Bicep.2.Parameters.json'
                'tests/PSRule.Rules.Azure.Tests/Resources.ServiceFabric.Parameters.json'
                'tests/PSRule.Rules.Azure.Tests/Resources.VirtualMachine.Parameters.json'
                'tests/PSRule.Rules.Azure.Tests/Resources.VMSS.Parameters.json'
            );

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 15;
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

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly 'The parameter ''vnetName'' must have a value or Key Vault reference set.';

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
            $ruleResult[0].Reason[0] | Should -Be 'Path reference.keyVault.id: Does not exist.';
            $ruleResult[0].Reason[1] | Should -Be 'Path reference.secretName: The field value ''not_a_secret'' does not match the pattern ''^[A-Za-z0-9-]{1,127}$''.';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $targetNames = $ruleResult | ForEach-Object { $_.TargetName.Split([char[]]@('\', '/'))[-1] };
            $targetNames | Should -BeIn 'Resources.Parameters.json', 'Resources.VPN.Parameters3.json';
        }

        It 'Azure.Template.UseComments' {
            $dataPath = @(
                Join-Path -Path $here -ChildPath 'Resources.Template.json'
                Join-Path -Path $here -ChildPath 'Resources.Template2.json'
                Join-Path -Path $here -ChildPath 'Resources.Template3.json'
                Join-Path -Path $here -ChildPath 'Resources.Template4.json'
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.UseComments';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.UseComments' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' } | Sort-Object -Property { $_.TargetName.Replace('\', '/').Split('/')[-1] });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;

            $ruleResult.TargetName.Replace('\', '/').Split('/')[-1] | Should -BeIn @(
                'Resources.Template2.json'
                'Resources.Template3.json'
                'Resources.Template4.json'
            );

            $ruleResult[0].Reason.Length | Should -Be 1;
            $ruleResult[0].Reason[0] | Should -BeExactly "The template ($($ruleResult[0].TargetObject.FullName)) has (5) resource/s without comments.";

            $ruleResult[1].Reason.Length | Should -Be 1;
            $ruleResult[1].Reason[0] | Should -BeExactly "The template ($($ruleResult[1].TargetObject.FullName)) has (4) resource/s without comments.";

            $ruleResult[2].Reason.Length | Should -Be 1;
            $ruleResult[2].Reason[0] | Should -BeExactly "The template ($($ruleResult[2].TargetObject.FullName)) has (4) resource/s without comments.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName.Replace('\', '/').Split('/')[-1] | Should -Be 'Resources.Template.json';
        }

        It 'Azure.Template.UseDescriptions' {
            $dataPath = @(
                Join-Path -Path $here -ChildPath 'Resources.Template.Bicep1.json'
                Join-Path -Path $here -ChildPath 'Resources.Template.Bicep2.json'
            );
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Format None -Name 'Azure.Template.UseDescriptions';
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.Template.UseDescriptions' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;

            $ruleResult.TargetName.Replace('\', '/').Split('/')[-1] | Should -Be 'Resources.Template.Bicep1.json';

            $ruleResult[0].Reason.Length | Should -Be 1;
            $ruleResult[0].Reason[0] | Should -BeExactly "The template ($($ruleResult[0].TargetObject.FullName)) has (4) resource/s without descriptions.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName.Replace('\', '/').Split('/')[-1] | Should -Be 'Resources.Template.Bicep2.json';
        }
    }
}
