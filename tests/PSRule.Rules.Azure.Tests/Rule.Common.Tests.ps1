# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure resource tags
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

Describe 'SupportsTags' -Tag 'Common', 'Filters', 'SupportsTags' {
    $invokeParams = @{
        Baseline = 'Azure.All'
        Module = 'PSRule.Rules.Azure'
        WarningAction = 'Ignore'
        ErrorAction = 'Stop'
    }
    $tempResource = [PSCustomObject]@{
        Type = 'None'
    }

    Context 'Supports tags' {
        # Supported types
        $resourceTypes = @(
            'Microsoft.ContainerRegistry/registries'
            'Microsoft.Network/networkSecurityGroups'
            'Microsoft.Network/routeTables'
            'Microsoft.Resources/resourceGroups'
            'Microsoft.CostManagement/Connectors'
        )
        foreach ($resourceType in $resourceTypes) {
            It $resourceType {
                $tempResource.Type = $resourceType;
                $result = $tempResource | Invoke-PSRule @invokeParams -Name 'Azure.Resource.UseTags' -Outcome All;
                $result.Outcome | Should -Be 'Fail';
            }
        }
    }

    Context 'Does not support tags' {
        $resourceTypes = @(
            'Microsoft.Authorization/policyDefinitions'
            'Microsoft.Authorization/policySetDefinitions'
            'Microsoft.Authorization/policyAssignments'
            'microsoft.insights/diagnosticSettings'
            'Microsoft.KeyVault/vaults/providers/diagnosticSettings'
            'Microsoft.CostManagement/budgets'
        )
        foreach ($resourceType in $resourceTypes) {
            It $resourceType {
                $tempResource.Type = $resourceType;
                $result = $tempResource | Invoke-PSRule @invokeParams -Name 'Azure.Resource.UseTags' -Outcome All;
                $result.Outcome | Should -Be 'None';
            }
        }
    }
}
