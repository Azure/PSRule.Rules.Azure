# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure DocumentDB rules
#

[CmdletBinding()]
param ()

BeforeAll {
    $ErrorActionPreference = 'Stop';
    Set-StrictMode -Version latest;

    if ($Env:SYSTEM_DEBUG -eq 'true') {
        $VerbosePreference = 'Continue';
    }

    $rootPath = $PWD;
    Import-Module (Join-Path -Path $rootPath -ChildPath out/modules/PSRule.Rules.Azure) -Force;
    $here = (Resolve-Path $PSScriptRoot).Path;
    $invokeParams = @{
        Baseline      = 'Azure.All'
        Module        = 'PSRule.Rules.Azure'
        WarningAction = 'Ignore'
        ErrorAction   = 'Stop'
    }
    $dataPath = Join-Path -Path $here -ChildPath 'Resources.DocumentDB.json';
}

Describe 'Azure.DocumentDB' -Tag 'DocumentDB' {
    Context 'Conditions' {
        BeforeAll {
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.DocumentDB.EntraID' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.DocumentDB.EntraID' };

            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'mongodb-a';
            $ruleResult[0].Reason | Should -Be "Path properties.authConfig.allowedModes[*]: The value 'System.String[]' does not contain any of 'System.String[]'.";

            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'mongodb-b', 'mongodb-c', 'mongodb-d', 'mongodb-e';
        }

        It 'Azure.DocumentDB.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.DocumentDB.AvailabilityZone' };

            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' } | Sort-Object TargetName);
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'mongodb-a', 'mongodb-b', 'mongodb-c';
            $ruleResult[0].Reason | Should -Be "Path properties.highAvailability.targetMode: The Azure DocumentDB cluster (mongodb-a) location (East US) should have zone redundancy enabled.";
            $ruleResult[1].Reason | Should -Be "Path properties.highAvailability.targetMode: The Azure DocumentDB cluster (mongodb-b) location (East US) should have zone redundancy enabled.";
            $ruleResult[2].Reason | Should -Be "Path properties.highAvailability.targetMode: The Azure DocumentDB cluster (mongodb-c) location (East US) should have zone redundancy enabled.";

            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'mongodb-d', 'mongodb-e';
        }

        It 'Fails Entra ID authentication when allowed modes are missing or empty' {
            foreach ($properties in @(@{}, @{ authConfig = @{ allowedModes = @() } })) {
                $resource = @{
                    Name = 'documentdb'
                    Type = 'Microsoft.DocumentDB/mongoClusters'
                    Properties = $properties
                }
                $ruleResult = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.EntraID');
                $ruleResult.Length | Should -Be 1;
                $ruleResult[0].Outcome | Should -Be 'Fail';
            }
        }

        It 'Does not apply DocumentDB rules to Cosmos DB accounts' {
            $resource = @{
                Name = 'cosmos'
                Type = 'Microsoft.DocumentDB/databaseAccounts'
                Location = 'East US'
                Properties = @{}
            }
            $ruleResult = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.*' -Outcome Pass, Fail);
            $ruleResult.Length | Should -Be 0;
        }
    }

    Context 'Compatibility aliases' {
        It 'Selects the renamed rule through <Alias>' -ForEach @(
            @{ Alias = 'Azure.Cosmos.MongoEntraID'; Name = 'Azure.DocumentDB.EntraID'; Ref = 'AZR-000499' }
            @{ Alias = 'Azure.Cosmos.MongoAvailabilityZone'; Name = 'Azure.DocumentDB.AvailabilityZone'; Ref = 'AZR-000503' }
        ) {
            $rules = @(Get-PSRule -Module PSRule.Rules.Azure -Name $Alias -WarningAction Ignore);
            $rules.Length | Should -Be 1;
            $rules[0].Name | Should -Be $Name;
            $rules[0].Ref.Name | Should -Be $Ref;
            $rules[0].Tag.ruleSet | Should -Be '2025_12';

            $result = @(Invoke-PSRule @invokeParams -InputPath $dataPath -Name $Alias);
            $result.Length | Should -Be 5;
            $result.RuleName | Should -BeIn $Name;
        }

        It 'Excludes the renamed rule through <Alias>' -ForEach @(
            @{ Alias = 'Azure.Cosmos.MongoEntraID'; Name = 'Azure.DocumentDB.EntraID' }
            @{ Alias = 'Azure.Cosmos.MongoAvailabilityZone'; Name = 'Azure.DocumentDB.AvailabilityZone' }
        ) {
            $option = New-PSRuleOption;
            $option.Rule.Exclude = @($Alias);
            $result = @(Invoke-PSRule @invokeParams -InputPath $dataPath -Option $option);
            @($result | Where-Object { $_.RuleName -eq $Name }).Length | Should -Be 0;
        }

        It 'Suppresses the renamed rule through <Alias>' -ForEach @(
            @{ Alias = 'Azure.Cosmos.MongoEntraID'; Name = 'Azure.DocumentDB.EntraID' }
            @{ Alias = 'Azure.Cosmos.MongoAvailabilityZone'; Name = 'Azure.DocumentDB.AvailabilityZone' }
        ) {
            $option = New-PSRuleOption -SuppressTargetName @{ $Alias = @('mongodb-a') };
            $result = @(Invoke-PSRule @invokeParams -InputPath $dataPath -Name $Name -Option $option -Outcome All);
            $suppressed = @($result | Where-Object { $_.TargetName -eq 'mongodb-a' });
            $suppressed.Length | Should -Be 1;
            $suppressed[0].Outcome | Should -Be 'None';
            $suppressed[0].OutcomeReason | Should -Be 'Suppressed';
        }

        It 'Retains historical quarterly baseline membership' {
            $rules = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline 'Azure.GA_2025_12' -Name 'Azure.DocumentDB.*' -WarningAction Ignore);
            $rules.Length | Should -Be 2;
            $rules.Name | Should -BeIn 'Azure.DocumentDB.EntraID', 'Azure.DocumentDB.AvailabilityZone';
        }
    }
}
