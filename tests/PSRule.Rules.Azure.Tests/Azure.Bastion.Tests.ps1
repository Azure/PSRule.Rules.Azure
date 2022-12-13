# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure Bastion rules
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

Context 'Resource name - Azure.Bastion.Name' {
    BeforeAll {
        $invokeParams = @{
            Baseline = 'Azure.All'
            Module = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction = 'Stop'
        }

        $testObject = [PSCustomObject]@{
            Name = ''
            ResourceType = 'Microsoft.Network/bastionHosts'
        }
    }

    BeforeDiscovery {
        $validNames = @(
            'a'
            'A'
            'a_'
            'A_'
            '1'
            '1_'
            'contoso-001-bas'
            'contoso.001.bas'
            'contoso_001_bas'
            'contoso-001-bas_'
            'contoso.001.bas_'
            'contoso_001_bas_'
            'CONTOSO-001-BAS'
            'contoso.001.BAS'
            'contoso_001_BAS'
            'CONTOSO-001-BAS_'
            'CONTOSO.001.bas_'
            'contoso_001_BAS_'
        )

        $invalidNames = @(
            'a-'
            'A-'
            '_a'
            '_A'
            '-a'
            '-A'
            '_1'
            '-1'
            '-'
            '_'
            '-contoso-001-bas'
            '-contoso-001-bas-'
            '-_contoso-001-bas'
            'CONTOSO-001-BAS.'
            'CONTOSO-001-BAS-'
            'CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-CONTOSO-001-BAS'
        )
    }

    # Pass
    It '<_>' -ForEach $validNames {
        $testObject.Name = $_;
        $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.Bastion.Name';
        $ruleResult | Should -Not -BeNullOrEmpty;
        $ruleResult.Outcome | Should -Be 'Pass';
    }

    # Fail
    It '<_>' -ForEach $invalidNames {
        $testObject.Name = $_;
        $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.Bastion.Name';
        $ruleResult | Should -Not -BeNullOrEmpty;
        $ruleResult.Outcome | Should -Be 'Fail';
    }
}
