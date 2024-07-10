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
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.AppService.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.AppService.PlanInstanceCount' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.PlanInstanceCount' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'plan-B', 'plan-C', 'plan-D';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'sku.capacity';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'plan-A', 'plan-E';
        }

        It 'Azure.AppService.MinPlan' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.MinPlan' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'plan-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'sku.tier';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -Be 'plan-A', 'plan-C', 'plan-D', 'plan-E';
        }

        It 'Azure.AppService.ARRAffinity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.ARRAffinity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.clientAffinityEnabled';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 11;
            $ruleResult.TargetName | Should -BeIn 'site-A', 'site-A/staging', 'fn-app', 'site-c', 'site-d', 'site-e', 'site-f', 'site-g', 'site-h', 'site-i', 'site-j';
        }

        It 'Azure.AppService.UseHTTPS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.UseHTTPS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.httpsOnly';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 11;
            $ruleResult.TargetName | Should -BeIn 'site-A', 'site-A/staging', 'fn-app', 'site-c', 'site-d', 'site-e', 'site-f', 'site-g', 'site-h', 'site-i', 'site-j';
        }

        It 'Azure.AppService.MinTLS' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.MinTLS' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging', 'site-c', 'site-d', 'site-e', 'site-f', 'site-g', 'site-h', 'site-i', 'site-j';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.siteConfig.minTlsVersion', 'resources[0].properties.minTlsVersion';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "Path resources[0].properties.minTlsVersion: Minimum TLS version is set to 1.1.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "Path resources[0].properties.minTlsVersion: Minimum TLS version is set to 1.1.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'site-A', 'site-A/staging', 'fn-app';
        }

        It 'Azure.AppService.RemoteDebug' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.RemoteDebug' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging', 'site-c', 'site-d', 'site-e', 'site-f', 'site-g', 'site-h';
            # TODO: $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.siteConfig.remoteDebuggingEnabled';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'site-A', 'site-A/staging', 'fn-app', 'site-i', 'site-j';
        }

        It 'Azure.AppService.NETVersion' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.NETVersion' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult[0].Reason | Should -BeExactly "Path resources[0].properties.netFrameworkVersion: The version '3.5.-1' does not match the constraint '4.0 || >=8.0'.";
            $ruleResult[1].Reason | Should -BeExactly "Path resources[0].properties.netFrameworkVersion: The version '3.5.-1' does not match the constraint '4.0 || >=8.0'.";
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.siteConfig.netFrameworkVersion', 'resources[0].properties.netFrameworkVersion';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 11;
            $ruleResult.TargetName | Should -BeIn 'site-A', 'site-A/staging', 'fn-app', 'site-c', 'site-d', 'site-e', 'site-f', 'site-g', 'site-h', 'site-i', 'site-j';
        }

        It 'Azure.AppService.PHPVersion' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.PHPVersion' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            # $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'site-B', 'site-B/staging', 'site-d';
            $ruleResult[0].Reason | Should -BeExactly "Path resources[0].properties.phpVersion: The version '5.6.-1' does not match the constraint '>=8.2'.";
            $ruleResult[1].Reason | Should -BeExactly "Path resources[0].properties.phpVersion: The version '5.6.-1' does not match the constraint '>=8.2'.";
            $ruleResult[2].Reason | Should -BeExactly "Path properties.siteConfig.linuxFxVersion..: The version '8.1.-1' does not match the constraint '>=8.2'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -Be 'site-A', 'site-A/staging', 'fn-app', 'site-c', 'site-e', 'site-f', 'site-g', 'site-h', 'site-i', 'site-j';
        }

        It 'Azure.AppService.AlwaysOn' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.AlwaysOn' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging', 'site-c', 'site-d', 'site-e', 'site-f', 'site-g', 'site-h', 'site-i', 'site-j';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'site-A', 'site-A/staging';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' -and $_.TargetType -eq 'Microsoft.Web/sites' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'fn-app';
        }

        It 'Azure.AppService.HTTP2' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.HTTP2' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging', 'site-c', 'site-d', 'site-e', 'site-f', 'site-g', 'site-h', 'site-i', 'site-j';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'site-A', 'site-A/staging', 'fn-app';
        }

        It 'Azure.AppService.ManagedIdentity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.ManagedIdentity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -Be 'site-B', 'site-B/staging', 'site-c', 'site-d', 'site-e', 'site-f', 'site-g', 'site-h', 'site-i', 'site-j';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'site-A', 'site-A/staging', 'fn-app';
        }

        It 'Azure.AppService.NodeJsVersion' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.NodeJsVersion' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -Be 'site-e', 'site-g', 'site-i', 'site-k/web', 'site-m/web', 'site-o/appsettings';

            $ruleResult[0].Reason | Should -BeExactly "Path .: The version '19.0.-1' does not match the constraint '>=20.0.0'.";
            $ruleResult[1].Reason | Should -BeExactly "Path .: The version '19.0.-1' does not match the constraint '>=20.0.0'.";
            $ruleResult[2].Reason | Should -BeExactly "Path .: The version '19.0.-1' does not match the constraint '>=20.0.0'.";
            $ruleResult[3].Reason | Should -BeExactly "Path .: The version '18.0.-1' does not match the constraint '>=20.0.0'.";
            $ruleResult[4].Reason | Should -BeExactly "Path .: The version '18.0.-1' does not match the constraint '>=20.0.0'.";
            $ruleResult[5].Reason | Should -BeExactly "Path .: The version '18.0.-1' does not match the constraint '>=20.0.0'.";
            
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 13;
            $ruleResult.TargetName | Should -BeIn 'site-A', 'site-A/staging', 'site-B', 'site-B/staging', 'fn-app', 'site-c', 'site-d', 'site-f', 'site-h', 'site-j', 'site-l/web', 'site-n/web', 'site-p/appsettings';
        }

        It 'Azure.AppService.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'plan-A', 'plan-B', 'plan-D';

            $ruleResult[0].Reason | Should -BeExactly "The app service plan (plan-A) is not deployed with a SKU that supports zone-redundancy.";
            $ruleResult[1].Reason | Should -BeExactly "The app service plan (plan-B) is not deployed with a SKU that supports zone-redundancy.";
            $ruleResult[2].Reason | Should -BeExactly "The app service plan (plan-D) deployed to region (eastus) should use a minimum of two availability zones from the following [1, 2, 3].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -Be 'plan-C', 'plan-E', 'plan-F';
        }
    }

    Context 'With Template' {
        BeforeAll {
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.AppService.json;
            Get-AzRuleTemplateLink -Path $here -InputPath 'Resources.AppService.Parameters.json' | Export-AzRuleTemplateData -OutputPath $outputFile;
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
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
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'plan-b', 'plan-d';

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
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'plan-a', 'plan-b', 'plan-d';

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
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'app-a', 'app-b', 'app-c', 'app-d', 'app-e';
        }

        It 'Azure.AppService.RemoteDebug' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.RemoteDebug' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'app-a', 'app-b', 'app-c', 'app-d', 'app-e';
        }

        It 'Azure.AppService.NETVersion' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.NETVersion' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            # $ruleResult.Length | Should -Be 3;
            # $ruleResult[0].Reason | Should -BeExactly "Path properties.siteConfig.netFrameworkVersion: The version '6.0.-1' does not match the constraint '4.0 || >=8.0'.";
            # $ruleResult[1].Reason | Should -BeExactly "Path properties.siteConfig.netFrameworkVersion: The version '6.0.-1' does not match the constraint '4.0 || >=8.0'.";
            # $ruleResult[2].Reason | Should -BeExactly "Path properties.siteConfig.netFrameworkVersion: The version '6.0.-1' does not match the constraint '4.0 || >=8.0'.";
            $ruleResult.TargetName | Should -BeIn 'app-c', 'app-d';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            # $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'app-a', 'app-b', 'app-e';
        }

        It 'Azure.AppService.PHPVersion' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.PHPVersion' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'app-a', 'app-b', 'app-c', 'app-d', 'app-e';
        }

        It 'Azure.AppService.AlwaysOn' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.AlwaysOn' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'app-a', 'app-b', 'app-c', 'app-d', 'app-e';
        }

        It 'Azure.AppService.HTTP2' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.HTTP2' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'app-a', 'app-b', 'app-c', 'app-d', 'app-e';
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
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'app-b', 'app-c', 'app-d', 'app-e';
        }

        It 'Azure.AppService.WebProbe' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.WebProbe' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'app-a';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'app-b', 'app-c', 'app-d', 'app-e';
        }

        It 'Azure.AppService.WebProbePath' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.WebProbePath' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'app-a', 'app-b';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'app-c', 'app-d', 'app-e';
        }
    }

    Context 'Web App' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.AppService.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath; 
        }

        It 'Azure.AppService.WebProbe' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.WebProbe' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -BeIn 'site-B', 'site-B/staging', 'site-c', 'site-d', 'site-e', 'site-f', 'site-g', 'site-h', 'site-i', 'site-j';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'site-A', 'site-A/staging';
        }

        It 'Azure.AppService.WebProbePath' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.WebProbePath' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 11;
            $ruleResult.TargetName | Should -BeIn 'site-B', 'site-B/staging', 'site-A/staging', 'site-c', 'site-d', 'site-e', 'site-f', 'site-g', 'site-h', 'site-i', 'site-j';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'site-A';
        }

        It 'Azure.AppService.WebSecureFtp' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.AppService.WebSecureFtp' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 9;
            $ruleResult.TargetName | Should -BeIn 'site-B', 'site-c', 'site-d', 'site-e', 'site-f', 'site-g', 'site-h', 'site-i', 'site-j';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'site-A', 'site-A/staging', 'site-B/staging';
        }
    }
}
