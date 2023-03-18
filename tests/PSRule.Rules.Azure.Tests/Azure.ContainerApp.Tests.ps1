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
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
                Outcome = 'All'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.ContainerApp.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.ContainerApp.Insecure' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.Insecure' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'capp-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'capp-A';
        }
    }
}

Context 'Resource name - Azure.ContainerApp.Name' {
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
            'app-01'
            'a1'
            'application-01'
        )

        $invalidNames = @(
            'a'
            'app-a'
            'app-a-'
            'APP-A'
            'app-01!'
            'app.-01'
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaapplication-01'
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
