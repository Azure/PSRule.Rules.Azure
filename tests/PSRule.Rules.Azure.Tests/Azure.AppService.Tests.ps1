# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure App Services rules
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

Describe 'Azure.AppService' -Tag 'AppService' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.AppService.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath; 
        }

        It 'Azure.AppService.PlanInstanceCount' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.PlanInstanceCount' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'plan-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'plan-A';
        }

        It 'Azure.AppService.MinPlan' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.MinPlan' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'plan-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'plan-A';
        }

        It 'Azure.AppService.ARRAffinity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.ARRAffinity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-A', 'site-A/staging';
        }

        It 'Azure.AppService.UseHTTPS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.UseHTTPS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-A', 'site-A/staging';
        }

        It 'Azure.AppService.MinTLS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.MinTLS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Minimum TLS version is set to 1.1.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Minimum TLS version is set to 1.1.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-A', 'site-A/staging';
        }

        It 'Azure.AppService.RemoteDebug' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.RemoteDebug' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-A', 'site-A/staging';
        }

        It 'Azure.AppService.NETVersion' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.NETVersion' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-A', 'site-A/staging';
        }

        It 'Azure.AppService.PHPVersion' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.PHPVersion' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-A', 'site-A/staging';
        }

        It 'Azure.AppService.AlwaysOn' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.AlwaysOn' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-A', 'site-A/staging';
        }

        It 'Azure.AppService.HTTP2' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.HTTP2' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-A', 'site-A/staging';
        }

        It 'Azure.AppService.ManagedIdentity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.ManagedIdentity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-A', 'site-A/staging';
        }
    }

    Context 'With Template' {
        BeforeAll {
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.AppService.json;
            Get-AzRuleTemplateLink -Path $here -InputPath 'Resources.AppService.Parameters.json' | Export-AzRuleTemplateData -OutputPath $outputFile;
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $result = Invoke-PSRule @invokeParams -InputPath $outputFile -Outcome All;
        }

        It 'Azure.AppService.PlanInstanceCount' {
            $filteredResult = $result | Where-Object {
                $_.RuleName -eq 'Azure.AppService.PlanInstanceCount' -and
                $_.TargetType -eq 'Microsoft.Web/serverfarms'
            };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'plan-a';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'plan-b';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'plan-c';
        }

        It 'Azure.AppService.MinPlan' {
            $filteredResult = $result | Where-Object {
                $_.RuleName -eq 'Azure.AppService.MinPlan' -and
                $_.TargetType -eq 'Microsoft.Web/serverfarms'
            };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.TargetName | Should -BeIn 'plan-a';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'plan-b';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'plan-c';
        }

        It 'Azure.AppService.MinTLS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.MinTLS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'app-a', 'app-b', 'app-c';
        }

        It 'Azure.AppService.RemoteDebug' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.RemoteDebug' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'app-a', 'app-b', 'app-c';
        }

        It 'Azure.AppService.NETVersion' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.NETVersion' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'app-a', 'app-b', 'app-c';
        }

        It 'Azure.AppService.PHPVersion' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.PHPVersion' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'app-a', 'app-b', 'app-c';
        }

        It 'Azure.AppService.AlwaysOn' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.AlwaysOn' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'app-a', 'app-b', 'app-c';
        }

        It 'Azure.AppService.HTTP2' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.HTTP2' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'app-a', 'app-b', 'app-c';
        }

        It 'Azure.AppService.ManagedIdentity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.ManagedIdentity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'app-a';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'app-b', 'app-c';
        }
    }
}
