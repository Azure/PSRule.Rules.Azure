# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Container Apps
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

Describe 'Azure.ContainerApp' -Tag 'ContainerApp' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
                Outcome       = 'All'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.ContainerApp.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option @{
                'Configuration.AZURE_CONTAINERAPPS_RESTRICT_INGRESS' = $True
            }
        }

        It 'Azure.ContainerApp.Insecure' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.Insecure' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-B', 'capp-D';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-A', 'capp-C';
        }

        It 'Azure.ContainerApp.ManagedIdentity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.ManagedIdentity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-A', 'capp-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'identity.type'

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-C', 'capp-D';
        }

        It 'Azure.ContainerApp.PublicAccess' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.PublicAccess' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-env-A', 'capp-env-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.vnetConfiguration.internal'

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'capp-env-C';
        }

        It 'Azure.ContainerApp.ExternalIngress' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.ExternalIngress' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-B', 'capp-C';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.configuration.ingress.external'

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-A', 'capp-D';
        }

        It 'Azure.ContainerApp.Storage' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.Storage' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'capp-C';
            # Todo: $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.template.volumes.storageType'

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'capp-D';
        }

        It 'Azure.ContainerApp.DisableAffinity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.DisableAffinity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'capp-A';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.configuration.ingress.stickySessions.affinity'

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'capp-B', 'capp-C', 'capp-D';
        }

        It 'Azure.ContainerApp.RestrictIngress' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.RestrictIngress' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'capp-A', 'capp-B', 'capp-C';

            $ruleResult[0].Reason | Should -BeLike $null;
            $ruleResult[1].Reason | Should -BeLike "Path action: Is set to 'Deny'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'capp-D';
        }
    }
}

Context 'Resource name - Azure.ContainerApp.Name' {
    BeforeAll {
        $invokeParams = @{
            Baseline      = 'Azure.All'
            Module        = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction   = 'Stop'
        }

        $testObject = [PSCustomObject]@{
            Name         = ''
            ResourceType = 'Microsoft.App/containerApps'
        }
    }

    BeforeDiscovery {
        $validNames = @(
            'capp-01'
            'a1'
            'capplication-01'
        )

        $invalidNames = @(
            'a'
            'capp-.'
            'capp-a-'
            'CAPP-A'
            'capp-01!'
            'capp.-01'
            'caaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaapplication-01'
        )
    }

    # Pass
    It '<_>' -ForEach $validNames {
        $testObject.Name = $_;
        $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.ContainerApp.Name';
        $ruleResult | Should -Not -BeNullOrEmpty;
        $ruleResult.Outcome | Should -Be 'Pass';
    }

    # Fail
    It '<_>' -ForEach $invalidNames {
        $testObject.Name = $_;
        $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.ContainerApp.Name';
        $ruleResult | Should -Not -BeNullOrEmpty;
        $ruleResult.Outcome | Should -Be 'Fail';
    }
}
