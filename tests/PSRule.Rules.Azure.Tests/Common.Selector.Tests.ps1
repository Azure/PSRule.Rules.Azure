# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure resource tags
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

Describe 'SupportsTags' -Tag 'Common', 'Filters', 'SupportsTags' {
    BeforeAll {
        $invokeParams = @{
            Baseline      = 'Azure.All'
            Module        = 'PSRule.Rules.Azure'
            WarningAction = 'Ignore'
            ErrorAction   = 'Stop'
        }
        $tempResource = [PSCustomObject]@{
            Type = 'None'
        }
    }

    BeforeDiscovery {
        # Types to check
        $supportedTypes = @(
            'Microsoft.ContainerRegistry/registries'
            'Microsoft.Network/networkSecurityGroups'
            'Microsoft.Network/routeTables'
            'Microsoft.Resources/resourceGroups'
            'Microsoft.CostManagement/Connectors'
            'Microsoft.Automation/automationAccounts'
            'Microsoft.Automation/automationAccounts/runbooks'
            'Microsoft.Resources/templateSpecs'
            'Microsoft.Resources/templateSpecs/versions'
            'microsoft.insights/dataCollectionEndpoints'
            'microsoft.insights/components'
            'microsoft.insights/workbooks'
        )

        $notSupportedTypes = @(
            'Microsoft.Authorization/policyDefinitions'
            'Microsoft.Authorization/policySetDefinitions'
            'Microsoft.Authorization/policyAssignments'
            'microsoft.insights/diagnosticSettings'
            'Microsoft.KeyVault/vaults/providers/diagnosticSettings'
            'Microsoft.CostManagement/budgets'
            'Microsoft.Resources/links'
            'microsoft.insights/dataCollectionRuleAssociations'
            'microsoft.insights/logs'
            'Microsoft.AzureActiveDirectory/b2ctenants'
        )
    }

    Context 'Supports tags with selector' {
        It '<_>' -ForEach $supportedTypes {
            $tempResource.Type = $_;
            $result = $tempResource | Invoke-PSRule @invokeParams -Name 'Azure.Resource.UseTags' -Outcome All;
            $result.Outcome | Should -Be 'Fail';
        }
    }

    Context 'Does not support tags with selector' {
        It '<_>' -ForEach $notSupportedTypes {
            $tempResource.Type = $_;
            $result = $tempResource | Invoke-PSRule @invokeParams -Name 'Azure.Resource.UseTags' -Outcome All;
            $result.Outcome | Should -Be 'None';
        }
    }

    Context 'Supports tags with function' {
        It '<_>' -ForEach $supportedTypes {
            $tempResource.Type = $_;
            $result = $tempResource | Invoke-PSRule @invokeParams -Path $here/Common.Test.Rule.ps1 -Name 'Test.SupportsTags' -Outcome All;
            $result.Outcome | Should -Be 'Fail';
        }
    }

    Context 'Does not support tags with function' {
        It '<_>' -ForEach $notSupportedTypes {
            $tempResource.Type = $_;
            $result = $tempResource | Invoke-PSRule @invokeParams -Path $here/Common.Test.Rule.ps1 -Name 'Test.SupportsTags' -Outcome All;
            $result.Outcome | Should -Be 'None';
        }
    }
}
