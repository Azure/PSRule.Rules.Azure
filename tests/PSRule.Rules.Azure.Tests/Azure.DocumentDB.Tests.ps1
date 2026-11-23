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

    function New-DocumentDBTestResource {
        param (
            [hashtable]$Properties = @{},
            [object[]]$Resources = @()
        )
        @{
            Name = 'docdb-test'
            Type = 'Microsoft.DocumentDB/mongoClusters'
            Location = 'East US'
            Properties = $Properties
            Resources = $Resources
        } | ConvertTo-Json -Depth 20 | ConvertFrom-Json;
    }
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

    Context 'Public network access' {
        It 'Returns <Expected> for publicNetworkAccess <Value>' -ForEach @(
            @{ Value = 'Disabled'; Expected = 'Pass' }
            @{ Value = 'Enabled'; Expected = 'Fail' }
            @{ Value = ''; Expected = 'Fail' }
        ) {
            $resource = New-DocumentDBTestResource -Properties @{ publicNetworkAccess = $Value };
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.PublicAccess');
            $actual.Length | Should -Be 1;
            $actual[0].Outcome | Should -Be $Expected;
        }

        It 'Fails when public network access is unspecified' {
            $resource = New-DocumentDBTestResource;
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.PublicAccess');
            $actual[0].Outcome | Should -Be 'Fail';
        }
    }

    Context 'Native authentication' {
        It 'Returns <Expected> for exported cluster modes <Modes>' -ForEach @(
            @{ Modes = @('MicrosoftEntraID'); Expected = 'Pass' }
            @{ Modes = @('NativeAuth', 'MicrosoftEntraID'); Expected = 'Fail' }
            @{ Modes = @('NativeAuth'); Expected = 'Fail' }
            @{ Modes = @(); Expected = 'Fail' }
            @{ Modes = @('UnexpectedMode'); Expected = 'Fail' }
        ) {
            $resource = New-DocumentDBTestResource -Properties @{ authConfig = @{ allowedModes = $Modes } };
            $resource | Add-Member -NotePropertyName SubscriptionId -NotePropertyValue '00000000-0000-0000-0000-000000000000';
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.LocalAuth');
            $actual.Length | Should -Be 1;
            $actual[0].Outcome | Should -Be $Expected;
        }

        It 'Fails when authentication is unspecified on an exported cluster' {
            $resource = New-DocumentDBTestResource;
            $resource | Add-Member -NotePropertyName SubscriptionId -NotePropertyValue '00000000-0000-0000-0000-000000000000';
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.LocalAuth');
            $actual[0].Outcome | Should -Be 'Fail';
        }

        It 'Does not require disabling native authentication at initial deployment' {
            $resource = New-DocumentDBTestResource -Properties @{ authConfig = @{ allowedModes = @('NativeAuth', 'MicrosoftEntraID') } };
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.LocalAuth' -Outcome All);
            $actual.Length | Should -Be 1;
            $actual[0].OutcomeReason | Should -Be 'PreconditionFail';
        }
    }

    Context 'Cluster names' {
        It 'Returns <Expected> for name <Name>' -ForEach @(
            @{ Name = 'abc'; Expected = 'Pass' }
            @{ Name = 'a' * 40; Expected = 'Pass' }
            @{ Name = 'docdb-prod-001'; Expected = 'Pass' }
            @{ Name = '123'; Expected = 'Pass' }
            @{ Name = 'ab'; Expected = 'Fail' }
            @{ Name = 'a' * 41; Expected = 'Fail' }
            @{ Name = 'Docdb'; Expected = 'Fail' }
            @{ Name = '-docdb'; Expected = 'Fail' }
            @{ Name = 'docdb-'; Expected = 'Fail' }
            @{ Name = 'docdb--test'; Expected = 'Fail' }
            @{ Name = 'docdb_test'; Expected = 'Fail' }
            @{ Name = 'docdb.test'; Expected = 'Fail' }
        ) {
            $resource = New-DocumentDBTestResource;
            $resource.Name = $Name;
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.Name');
            $actual[0].Outcome | Should -Be $Expected;
        }

        It 'Does not enforce an unconfigured naming convention' {
            $resource = New-DocumentDBTestResource;
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.Naming' -Outcome All);
            $actual[0].OutcomeReason | Should -Be 'PreconditionFail';
        }

        It 'Uses a case-sensitive custom name format for <Name>' -ForEach @(
            @{ Name = 'docdb-prod'; Expected = 'Pass' }
            @{ Name = 'mongo-prod'; Expected = 'Fail' }
            @{ Name = 'DOCDB-prod'; Expected = 'Fail' }
        ) {
            $option = New-PSRuleOption -Configuration @{ AZURE_DOCUMENTDB_CLUSTER_NAME_FORMAT = '^docdb-' };
            $resource = New-DocumentDBTestResource;
            $resource.Name = $Name;
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.Naming' -Option $option);
            $actual[0].Outcome | Should -Be $Expected;
        }
    }

    Context 'Firewall rules' {
        It 'Returns <Expected> for <Count> firewall rules of type <Type>' -ForEach @(
            @{ Count = 0; Type = 'Microsoft.DocumentDB/mongoClusters/firewallRules'; Expected = 'Pass' }
            @{ Count = 10; Type = 'Microsoft.DocumentDB/mongoClusters/firewallRules'; Expected = 'Pass' }
            @{ Count = 11; Type = 'Microsoft.DocumentDB/mongoClusters/firewallRules'; Expected = 'Fail' }
            @{ Count = 11; Type = 'firewallRules'; Expected = 'Fail' }
            @{ Count = 11; Type = 'Microsoft.Insights/diagnosticSettings'; Expected = 'Pass' }
        ) {
            $firewallRules = @(for ($i = 0; $i -lt $Count; $i++) {
                @{ Name = "rule-$i"; Type = $Type; Properties = @{ startIpAddress = '203.0.113.1'; endIpAddress = '203.0.113.1' } }
            });
            $resource = New-DocumentDBTestResource -Resources $firewallRules;
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.FirewallRuleCount');
            $actual[0].Outcome | Should -Be $Expected;
        }

        It 'Returns <Expected> for IP range <Start> to <End> (standalone: <Standalone>)' -ForEach @(
            @{ Start = '203.0.113.1'; End = '203.0.113.10'; Standalone = $False; Expected = 'Pass' }
            @{ Start = '203.0.113.1'; End = '203.0.113.11'; Standalone = $False; Expected = 'Fail' }
            @{ Start = '203.0.113.1'; End = '203.0.113.10'; Standalone = $True; Expected = 'Pass' }
            @{ Start = '203.0.113.1'; End = '203.0.113.11'; Standalone = $True; Expected = 'Fail' }
            @{ Start = '0.0.0.0'; End = '255.255.255.255'; Standalone = $False; Expected = 'Fail' }
            @{ Start = '0.0.0.0'; End = '255.255.255.255'; Standalone = $True; Expected = 'Fail' }
            @{ Start = '172.1.0.1'; End = '172.1.0.11'; Standalone = $False; Expected = 'Fail' }
            @{ Start = '0.0.0.0'; End = '0.0.0.0'; Standalone = $False; Expected = 'Pass' }
        ) {
            $firewall = @{ Name = 'allow-client'; Type = 'Microsoft.DocumentDB/mongoClusters/firewallRules'; Properties = @{ startIpAddress = $Start; endIpAddress = $End } };
            $resource = New-DocumentDBTestResource -Resources @($firewall);
            if ($Standalone) {
                $resource = $resource.Resources[0];
            }
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.FirewallIPRange');
            $actual[0].Outcome | Should -Be $Expected;
        }

        It 'Aggregates address counts across firewall rules' {
            $firewallRules = @(
                @{ Name = 'a'; Type = 'firewallRules'; Properties = @{ startIpAddress = '203.0.113.1'; endIpAddress = '203.0.113.6' } }
                @{ Name = 'b'; Type = 'firewallRules'; Properties = @{ startIpAddress = '203.0.113.10'; endIpAddress = '203.0.113.14' } }
            );
            $resource = New-DocumentDBTestResource -Resources $firewallRules;
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.FirewallIPRange');
            $actual[0].Outcome | Should -Be 'Fail';
            $actual[0].Reason | Should -Match '\(11\)';
        }

        It 'Fails explicitly for missing firewall address fields' {
            $resource = New-DocumentDBTestResource -Resources @(@{ Name = 'invalid'; Type = 'firewallRules'; Properties = @{} });
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.FirewallIPRange');
            $actual[0].Outcome | Should -Be 'Fail';
        }

        It 'Allows clusters without firewall rules' {
            $resource = New-DocumentDBTestResource;
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.FirewallIPRange', 'Azure.DocumentDB.AllowAzureAccess');
            $actual.Length | Should -Be 2;
            $actual.Outcome | Should -BeIn 'Pass';
        }

        It 'Returns <Expected> for Azure-wide access (standalone: <Standalone>)' -ForEach @(
            @{ Start = '0.0.0.0'; End = '0.0.0.0'; Standalone = $False; Expected = 'Fail' }
            @{ Start = '0.0.0.0'; End = '0.0.0.0'; Standalone = $True; Expected = 'Fail' }
            @{ Start = '203.0.113.1'; End = '203.0.113.1'; Standalone = $False; Expected = 'Pass' }
            @{ Start = '203.0.113.1'; End = '203.0.113.1'; Standalone = $True; Expected = 'Pass' }
        ) {
            $firewall = @{ Name = 'custom-name'; Type = 'Microsoft.DocumentDB/mongoClusters/firewallRules'; Properties = @{ startIpAddress = $Start; endIpAddress = $End } };
            $resource = New-DocumentDBTestResource -Resources @($firewall);
            if ($Standalone) {
                $resource = $resource.Resources[0];
            }
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.AllowAzureAccess');
            $actual[0].Outcome | Should -Be $Expected;
        }
    }

    Context 'Diagnostic logs' {
        It 'Returns <Expected> for category <Category>, group <Group>, enabled <Enabled>' -ForEach @(
            @{ Category = 'vCoreMongoRequests'; Group = ''; Enabled = $True; Expected = 'Pass' }
            @{ Category = ''; Group = 'allLogs'; Enabled = $True; Expected = 'Pass' }
            @{ Category = 'vCoreMongoRequests'; Group = ''; Enabled = $False; Expected = 'Fail' }
            @{ Category = 'Unrelated'; Group = ''; Enabled = $True; Expected = 'Fail' }
            @{ Category = ''; Group = 'audit'; Enabled = $True; Expected = 'Fail' }
        ) {
            $diagnostic = @{ Name = 'logs'; Type = 'Microsoft.Insights/diagnosticSettings'; Properties = @{ logs = @(@{ category = $Category; categoryGroup = $Group; enabled = $Enabled }) } };
            $resource = New-DocumentDBTestResource -Properties @{ compute = @{ tier = 'M40' } } -Resources @($diagnostic);
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.DiagnosticLogs');
            $actual[0].Outcome | Should -Be $Expected;
        }

        It 'Fails without diagnostic settings on <Tier>' -ForEach @(
            @{ Tier = 'M40' }, @{ Tier = 'M80' }, @{ Tier = 'M200' }
        ) {
            $resource = New-DocumentDBTestResource -Properties @{ compute = @{ tier = $Tier } };
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.DiagnosticLogs');
            $actual[0].Outcome | Should -Be 'Fail';
        }

        It 'Does not require unsupported logs on <Tier>' -ForEach @(
            @{ Tier = 'M10' }, @{ Tier = 'M20' }, @{ Tier = 'M25' }, @{ Tier = 'M30' }, @{ Tier = 'Free' }, @{ Tier = '' }
        ) {
            $resource = New-DocumentDBTestResource -Properties @{ compute = @{ tier = $Tier } };
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.DiagnosticLogs' -Outcome All);
            $actual[0].OutcomeReason | Should -Be 'PreconditionFail';
        }
    }

    Context 'Customer-managed keys' {
        BeforeAll {
            $cmkOption = New-PSRuleOption -Configuration @{ AZURE_DOCUMENTDB_REQUIRE_CMK = $True };
            $identityId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/documentdb';
        }

        It 'Does not require customer-managed keys by default' {
            $resource = New-DocumentDBTestResource;
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.CMK' -Outcome All);
            $actual[0].OutcomeReason | Should -Be 'PreconditionFail';
        }

        It 'Fails when customer-managed keys are required but unspecified' {
            $resource = New-DocumentDBTestResource;
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.CMK' -Option $cmkOption);
            $actual[0].Outcome | Should -Be 'Fail';
        }

        It 'Returns <Expected> for CMK configuration <Case>' -ForEach @(
            @{ Case = 'Complete'; Expected = 'Pass' }
            @{ Case = 'MissingKey'; Expected = 'Fail' }
            @{ Case = 'EmptyKey'; Expected = 'Fail' }
            @{ Case = 'MissingIdentity'; Expected = 'Fail' }
            @{ Case = 'WrongIdentity'; Expected = 'Fail' }
            @{ Case = 'UnattachedIdentity'; Expected = 'Fail' }
            @{ Case = 'SystemAssignedOnly'; Expected = 'Fail' }
        ) {
            $cmk = @{
                keyEncryptionKeyUrl = 'https://documentdb-test.vault.azure.net/keys/documentdb'
                keyEncryptionKeyIdentity = @{ identityType = 'UserAssignedIdentity'; userAssignedIdentityResourceId = $identityId }
            };
            $resource = New-DocumentDBTestResource -Properties @{ encryption = @{ customerManagedKeyEncryption = $cmk } };
            $resource | Add-Member -NotePropertyName identity -NotePropertyValue ([pscustomobject]@{
                type = 'UserAssigned'
                userAssignedIdentities = [pscustomobject]@{ $identityId = [pscustomobject]@{} }
            });
            switch ($Case) {
                'MissingKey' { $resource.Properties.encryption.customerManagedKeyEncryption.PSObject.Properties.Remove('keyEncryptionKeyUrl') }
                'EmptyKey' { $resource.Properties.encryption.customerManagedKeyEncryption.keyEncryptionKeyUrl = '' }
                'MissingIdentity' { $resource.Properties.encryption.customerManagedKeyEncryption.PSObject.Properties.Remove('keyEncryptionKeyIdentity') }
                'WrongIdentity' { $resource.Properties.encryption.customerManagedKeyEncryption.keyEncryptionKeyIdentity.identityType = 'SystemAssignedIdentity' }
                'UnattachedIdentity' { $resource.identity.userAssignedIdentities = [pscustomobject]@{} }
                'SystemAssignedOnly' { $resource.identity.type = 'SystemAssigned' }
            }
            $actual = @($resource | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.CMK' -Option $cmkOption);
            $actual[0].Outcome | Should -Be $Expected;
        }
    }

    Context 'New rule metadata' {
        It 'Passes repository authoring validation for DocumentDB rules, including the 2027 rule set' {
            $rules = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline Azure.All -Name 'Azure.DocumentDB.*' -WarningAction Ignore);
            $authoringResults = @($rules | Invoke-PSRule -Path (Join-Path $rootPath '.ps-rule') -ErrorAction Stop -WarningAction Ignore -Outcome All);
            $authoringResults.Length | Should -BeGreaterThan 0;
            @($authoringResults | Where-Object { $_.Outcome -eq 'Fail' }).Length | Should -Be 0;
            @($authoringResults | Where-Object { $_.RuleName -eq 'Rule.RuleSet' -and $_.Outcome -eq 'Pass' }).Length | Should -Be 11;
        }

        It 'Uses unique references and the next quarterly rule set for all nine new checks' {
            $rules = @(Get-PSRule -Module PSRule.Rules.Azure -Baseline Azure.All -Name 'Azure.DocumentDB.*' -WarningAction Ignore);
            $newRules = @($rules | Where-Object { $_.Tag.ruleSet -eq '2027_03' });
            $rules.Length | Should -Be 11;
            $newRules.Length | Should -Be 9;
            @($newRules.Ref.Name | Sort-Object -Unique).Length | Should -Be 9;
            $newRules.Ref.Name | Should -BeIn @('AZR-000546', 'AZR-000547', 'AZR-000548', 'AZR-000549', 'AZR-000550', 'AZR-000551', 'AZR-000552', 'AZR-000553', 'AZR-000554');
        }

        It 'Uses DocumentDB display names for cluster mappings and identifies Cosmos MongoDB as RU-based' {
            $mappings = Get-Content -Raw (Join-Path $rootPath 'data\resource-type-mapping.json') | ConvertFrom-Json;
            $documentDBMappings = @($mappings | Where-Object { $_.ruleId -like 'Azure.DocumentDB.*' });
            $documentDBMappings.Length | Should -Be 11;
            foreach ($mapping in $documentDBMappings) {
                $mapping.resourceType | Should -Match '^Microsoft\.DocumentDB/mongoClusters';
                $mapping.displayName | Should -Match 'DocumentDB';
                $mapping.displayName | Should -Not -Match 'Cosmos DB';
            }
            $mongoMapping = $mappings | Where-Object { $_.ruleId -eq 'Azure.Cosmos.MongoNaming' };
            $mongoMapping.resourceType | Should -Be 'Microsoft.DocumentDB/databaseAccounts';
            $mongoMapping.displayName | Should -Match 'RU-based';
        }
    }

    Context 'With expanded template' {
        BeforeAll {
            $template = Join-Path $here 'Resources.DocumentDB.Template.json';
            $expanded = @(Export-AzRuleTemplateData -TemplateFile $template -PassThru);
            $option = New-PSRuleOption -Configuration @{
                AZURE_DOCUMENTDB_CLUSTER_NAME_FORMAT = '^docdb-'
                AZURE_DOCUMENTDB_REQUIRE_CMK = $True
            };
            $templateResults = @($expanded | Invoke-PSRule @invokeParams -Name 'Azure.DocumentDB.*' -Option $option -Outcome All);
        }

        It 'Associates firewall and diagnostic resources with the cluster and resolves encryption identities' {
            $clusterResults = @($templateResults | Where-Object { $_.TargetName -eq 'docdb-template' -and $_.Outcome -eq 'Pass' });
            $clusterResults.Length | Should -Be 10;
            $clusterResults.RuleName | Should -Contain 'Azure.DocumentDB.DiagnosticLogs';
            $clusterResults.RuleName | Should -Contain 'Azure.DocumentDB.CMK';
            $clusterResults.RuleName | Should -Contain 'Azure.DocumentDB.FirewallIPRange';
            @($templateResults | Where-Object { $_.Outcome -eq 'Fail' }).Length | Should -Be 0;
        }

        It 'Keeps native authentication allowed during initial deployment' {
            $localAuth = @($templateResults | Where-Object { $_.TargetName -eq 'docdb-template' -and $_.RuleName -eq 'Azure.DocumentDB.LocalAuth' });
            $localAuth.Length | Should -Be 1;
            $localAuth[0].OutcomeReason | Should -Be 'PreconditionFail';
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
