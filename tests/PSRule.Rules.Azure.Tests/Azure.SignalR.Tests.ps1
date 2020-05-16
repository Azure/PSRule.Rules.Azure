# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure SignalR rules
#

[CmdletBinding()]
param (

)

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

Describe 'Azure.SignalR' -Tag 'SignalR' {
    # $dataPath = Join-Path -Path $here -ChildPath 'Resources.SignalR.json';

    Context 'Resource name' {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }
        $validNames = @(
            'service1'
            'SERVICE-1'
        )
        $invalidNames = @(
            '_service1'
            '-service1'
            '1service'
            'se'
            's'
        )
        $testObject = [PSCustomObject]@{
            Name = ''
            ResourceType = 'Microsoft.SignalRService/signalR'
        }

        # Pass
        foreach ($name in $validNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.SignalR.Name';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Pass';
            }
        }

        # Fail
        foreach ($name in $invalidNames) {
            It $name {
                $testObject.Name = $name;
                $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.SignalR.Name';
                $ruleResult | Should -Not -BeNullOrEmpty;
                $ruleResult.Outcome | Should -Be 'Fail';
            }
        }
    }
}
