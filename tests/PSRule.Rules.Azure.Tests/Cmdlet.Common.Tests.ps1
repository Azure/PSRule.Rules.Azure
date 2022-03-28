# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for module cmdlets
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
    $outputPath = Join-Path -Path $rootPath -ChildPath out/tests/PSRule.Rules.Azure.Tests/Cmdlet;
    Remove-Item -Path $outputPath -Force -Recurse -Confirm:$False -ErrorAction Ignore;
    $Null = New-Item -Path $outputPath -ItemType Directory -Force;
    $here = (Resolve-Path $PSScriptRoot).Path;

    # Import Common rule functions
    Import-Module (Join-Path -Path $rootPath -ChildPath out/modules/PSRule.Rules.Azure/rules/Azure.Common.Rule.ps1) -Force;

    #region Mocks

    function MockContext {
        process {
            return @(
                (New-Object -TypeName Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext -ArgumentList @(
                    [PSCustomObject]@{
                        Subscription = [PSCustomObject]@{
                            Id    = '00000000-0000-0000-0000-000000000001'
                            Name  = 'Test subscription 1'
                            State = 'Enabled'
                        }
                        Tenant       = [PSCustomObject]@{
                            Id = '00000000-0000-0000-0000-000000000001'
                        }
                    }
                )),
                (New-Object -TypeName Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext -ArgumentList @(
                    [PSCustomObject]@{
                        Subscription = [PSCustomObject]@{
                            Id    = '00000000-0000-0000-0000-000000000002'
                            Name  = 'Test subscription 2'
                            State = 'Enabled'
                        }
                        Tenant       = [PSCustomObject]@{
                            Id = '00000000-0000-0000-0000-000000000002'
                        }
                    }
                ))
                (New-Object -TypeName Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext -ArgumentList @(
                    [PSCustomObject]@{
                        Subscription = [PSCustomObject]@{
                            Id    = '00000000-0000-0000-0000-000000000003'
                            Name  = 'Test subscription 3'
                            State = 'Enabled'
                        }
                        Tenant       = [PSCustomObject]@{
                            Id = '00000000-0000-0000-0000-000000000002'
                        }
                    }
                ))
            )
        }
    }

    function MockSingleSubscription {
        process {
            return @(
                (New-Object -TypeName Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext -ArgumentList @(
                    [PSCustomObject]@{
                        Subscription = [PSCustomObject]@{
                            Id    = '00000000-0000-0000-0000-000000000001'
                            Name  = 'Test subscription 1'
                            State = 'Enabled'
                        }
                        Tenant       = [PSCustomObject]@{
                            Id = '00000000-0000-0000-0000-000000000001'
                        }
                    }
                ))
            )
        }
    }

    #endregion Mocks
}

#region Export-AzRuleData

Describe 'Export-AzRuleData' -Tag 'Cmdlet', 'Export-AzRuleData' {
    Context 'With defaults' {
        BeforeAll {
            Mock -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith ${function:MockContext};
            Mock -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith {
                return @(
                    [PSCustomObject]@{
                        Name         = 'Resource1'
                        ResourceType = ''
                    }
                    [PSCustomObject]@{
                        Name         = 'Resource2'
                        ResourceType = ''
                    }
                )
            }
        }

        It 'Exports resources' {
            $result = @(Export-AzRuleData -OutputPath $outputPath);

            Assert-VerifiableMock;
            Assert-MockCalled -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -Times 3;
            Assert-MockCalled -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Times 1 -ParameterFilter {
                $ListAvailable -eq $False
            }
            Assert-MockCalled -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Times 0 -ParameterFilter {
                $ListAvailable -eq $True
            }
            $result.Length | Should -Be 3;
            $result | Should -BeOfType System.IO.FileInfo;

            # Check exported data
            $data = Get-Content -Path $result[0].FullName | ConvertFrom-Json;
            $data -is [System.Array] | Should -Be $True;
            $data.Length | Should -Be 2;
            $data.Name | Should -BeIn 'Resource1', 'Resource2';
        }

        It 'Return resources' {
            $result = @(Export-AzRuleData -PassThru);
            $result.Length | Should -Be 6;
            $result | Should -BeOfType PSCustomObject;
            $result.Name | Should -BeIn 'Resource1', 'Resource2';
        }
    }

    Context 'With filters' {
        BeforeAll {
            Mock -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -MockWith ${function:MockContext};
            Mock -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -MockWith {
                return @(
                    [PSCustomObject]@{
                        Name              = 'Resource1'
                        ResourceGroupName = 'rg-test-1'
                        ResourceType      = ''
                    }
                    [PSCustomObject]@{
                        Name              = 'Resource2'
                        ResourceGroupName = 'rg-test-2'
                        ResourceType      = ''
                    }
                )
            }
        }

        It '-Subscription with name filter' {
            $Null = Export-AzRuleData -Subscription 'Test subscription 1' -PassThru;
            Assert-MockCalled -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -Times 1;
            Assert-MockCalled -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Times 1 -ParameterFilter {
                $ListAvailable -eq $True
            }
        }

        It '-Subscription with Id filter' {
            $Null = Export-AzRuleData -Subscription '00000000-0000-0000-0000-000000000002' -PassThru;
            Assert-MockCalled -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -Times 1;
            Assert-MockCalled -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Times 1 -ParameterFilter {
                $ListAvailable -eq $True
            }
        }

        It '-Tenant filter' {
            $Null = Export-AzRuleData -Tenant '00000000-0000-0000-0000-000000000002' -PassThru;
            Assert-MockCalled -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -Times 2;
            Assert-MockCalled -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Times 1 -ParameterFilter {
                $ListAvailable -eq $True
            }
        }

        It '-ResourceGroupName filter' {
            $result = @(Export-AzRuleData -Subscription 'Test subscription 1' -ResourceGroupName 'rg-test-2' -PassThru);
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 1;
            $result[0].Name | Should -Be 'Resource2'
        }

        It '-Tag filter' {
            $Null = Export-AzRuleData -Subscription 'Test subscription 1' -Tag @{ environment = 'production' } -PassThru;
            Assert-MockCalled -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -Times 1 -ParameterFilter {
                $Tag.environment -eq 'production'
            }
        }
    }

    Context 'With data' {
        BeforeAll {
            Mock -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -MockWith ${function:MockSingleSubscription};
        }

        It 'Microsoft.Network/connections' {
            Mock -CommandName 'Get-AzResourceGroup' -ModuleName 'PSRule.Rules.Azure';
            Mock -CommandName 'Get-AzSubscription' -ModuleName 'PSRule.Rules.Azure';
            Mock -CommandName 'Get-AzResource' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith {
                return @(
                    [PSCustomObject]@{
                        Name         = 'Resource1'
                        ResourceType = 'Microsoft.Network/connections'
                        Id           = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/connections/cn001'
                        ResourceId   = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/connections/cn001'
                        Properties   = [PSCustomObject]@{ sharedKey = 'test123' }
                    }
                    [PSCustomObject]@{
                        Name         = 'Resource2'
                        ResourceType = 'Microsoft.Network/connections'
                        Id           = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/connections/cn002'
                        ResourceId   = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/connections/cn002'
                        Properties   = [PSCustomObject]@{ dummy = 'value' }
                    }
                )
            }
            $result = @(Export-AzRuleData -OutputPath $outputPath -PassThru);
            $result.Length | Should -Be 2;
            $result[0].Properties.sharedKey | Should -Be '*** MASKED ***';
        }

        It 'Microsoft.Storage/storageAccounts' {
            Mock -CommandName 'Get-AzResourceGroup' -ModuleName 'PSRule.Rules.Azure';
            Mock -CommandName 'Get-AzSubscription' -ModuleName 'PSRule.Rules.Azure';
            Mock -CommandName 'GetSubResource' -ModuleName 'PSRule.Rules.Azure' -Verifiable;
            Mock -CommandName 'Get-AzResource' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith {
                return @(
                    [PSCustomObject]@{
                        Name         = 'Resource1'
                        ResourceType = 'Microsoft.Storage/storageAccounts'
                        Kind         = 'StorageV2'
                        Id           = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/sa001'
                        ResourceId   = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/sa001'
                    }
                    [PSCustomObject]@{
                        Name         = 'Resource2'
                        ResourceType = 'Microsoft.Storage/storageAccounts'
                        Kind         = 'FileServices'
                        Id           = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/sa002'
                        ResourceId   = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/sa002'
                    }
                )
            }
            $Null = @(Export-AzRuleData -OutputPath $outputPath);
            Assert-MockCalled -CommandName 'GetSubResource' -ModuleName 'PSRule.Rules.Azure' -Times 1;
        }
    }
}

#endregion Export-AzRuleData

#region Export-AzRuleTemplateData

Describe 'Export-AzRuleTemplateData' -Tag 'Cmdlet', 'Export-AzRuleTemplateData' {
    BeforeAll {
        $templatePath = Join-Path -Path $here -ChildPath 'Resources.Template.json';
        $parametersPath = Join-Path -Path $here -ChildPath 'Resources.Parameters.json';
    }

    Context 'With defaults' {
        It 'Exports template' {
            $outputFile = Join-Path -Path $outputPath -ChildPath 'template-with-defaults.json'
            $exportParams = @{
                TemplateFile  = $templatePath
                ParameterFile = $parametersPath
                OutputPath    = $outputFile
            }
            $Null = Export-AzRuleTemplateData @exportParams;
            $result = Get-Content -Path $outputFile -Raw | ConvertFrom-Json;
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 11;
            $filteredResult = $result | Where-Object { $_.name -eq 'vnet-001' };
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.properties.addressSpace.addressPrefixes | Should -Be "10.1.0.0/24";
            $filteredResult.properties.subnets.Length | Should -Be 3;
            $filteredResult.properties.subnets[0].name | Should -Be 'GatewaySubnet';
            $filteredResult.properties.subnets[0].properties.addressPrefix | Should -Be '10.1.0.0/27';
            $filteredResult.properties.subnets[2].name | Should -Be 'subnet2';
            $filteredResult.properties.subnets[2].properties.addressPrefix | Should -Be '10.1.0.64/28';
            $filteredResult.properties.subnets[2].properties.networkSecurityGroup.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/networkSecurityGroups/nsg-subnet2$';
            $filteredResult.properties.subnets[2].properties.routeTable.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/routeTables/route-subnet2$';
        }

        It 'Returns file not found' {
            $exportParams = @{
                PassThru = $True
            }

            # Invalid template file
            $exportParams['TemplateFile'] = 'notafile.json';
            $exportParams['ParameterFile'] = $parametersPath;
            $errorOut = { $Null = Export-AzRuleTemplateData @exportParams -ErrorVariable exportErrors -ErrorAction SilentlyContinue; $exportErrors; } | Should -Throw -PassThru;
            $errorOut[0].Exception.Message | Should -BeLike "Unable to find the specified template file '*'.";

            # Invalid parameter file
            $exportParams['TemplateFile'] = $templatePath;
            $exportParams['ParameterFile'] = 'notafile.json';
            $errorOut = { $Null = Export-AzRuleTemplateData @exportParams -ErrorVariable exportErrors -ErrorAction SilentlyContinue; $exportErrors; } | Should -Throw -PassThru;
            $errorOut[0].Exception.Message | Should -BeLike "Unable to find the specified parameter file '*'.";
        }
    }

    Context 'With -PassThru' {
        It 'Exports template' {
            $exportParams = @{
                TemplateFile  = $templatePath
                ParameterFile = $parametersPath
            }
            $result = @(Export-AzRuleTemplateData @exportParams -PassThru);
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 11;
            $filteredResult = $result | Where-Object { $_.name -eq 'vnet-001' };
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.properties.subnets.Length | Should -Be 3;
            $filteredResult.properties.subnets[0].name | Should -Be 'GatewaySubnet';
            $filteredResult.properties.subnets[0].properties.addressPrefix | Should -Be '10.1.0.0/27';
            $filteredResult.properties.subnets[2].name | Should -Be 'subnet2';
            $filteredResult.properties.subnets[2].properties.addressPrefix | Should -Be '10.1.0.64/28';
            $filteredResult.properties.subnets[2].properties.networkSecurityGroup.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/networkSecurityGroups/nsg-subnet2$';
            $filteredResult.properties.subnets[2].properties.routeTable.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/routeTables/route-subnet2$';
        }
    }

    Context 'With -Subscription lookup' {
        It 'From context' {
            Mock -CommandName 'GetSubscription' -ModuleName 'PSRule.Rules.Azure' -MockWith {
                $result = [PSRule.Rules.Azure.Configuration.SubscriptionOption]::new();
                $result.SubscriptionId = '00000000-0000-0000-0000-000000000000';
                $result.TenantId = '00000000-0000-0000-0000-000000000000';
                $result.DisplayName = 'test-sub';
                return $result;
            }
            $exportParams = @{
                TemplateFile  = $templatePath
                ParameterFile = $parametersPath
                Subscription  = 'test-sub'
            }

            # With lookup
            $result = Export-AzRuleTemplateData @exportParams -PassThru;
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 11;
            $filteredResult = $result | Where-Object { $_.name -eq 'vnet-001' };
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.properties.subnets.Length | Should -Be 3;
            $filteredResult.properties.subnets[2].properties.networkSecurityGroup.id | Should -Match '^/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/networkSecurityGroups/nsg-subnet2$';
            $filteredResult.properties.subnets[2].properties.routeTable.id | Should -Match '^/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/routeTables/route-subnet2$';
            $filteredResult.tags.role | Should -Match 'Networking';
        }
    }

    Context 'With -Subscription object' {
        It 'From hashtable' {
            $exportParams = @{
                TemplateFile  = $templatePath
                ParameterFile = $parametersPath
                Subscription  = @{
                    SubscriptionId = 'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn';
                    TenantId       = 'nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn';
                }
            }
            $result = Export-AzRuleTemplateData @exportParams -PassThru;
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 11;
            $filteredResult = $result | Where-Object { $_.name -eq 'vnet-001' };
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.tags.role | Should -Be 'Custom';
        }
    }

    Context 'With -ResourceGroup lookup' {
        It 'From context' {
            Mock -CommandName 'GetResourceGroup' -ModuleName 'PSRule.Rules.Azure' -MockWith {
                $result = [PSRule.Rules.Azure.Configuration.ResourceGroupOption]::new();
                $result.Name = 'test-rg';
                $result.Location = 'region'
                $result.ManagedBy = 'testuser'
                $result.Tags = @{
                    test = 'true'
                }
                return $result;
            }
            $exportParams = @{
                TemplateFile  = $templatePath
                ParameterFile = $parametersPath
                ResourceGroup = 'test-rg'
            }

            # With lookup
            $result = Export-AzRuleTemplateData @exportParams -PassThru;
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 11;
            $filteredResult = $result | Where-Object { $_.name -eq 'vnet-001' };
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.properties.subnets.Length | Should -Be 3;
            $filteredResult.properties.subnets[2].properties.networkSecurityGroup.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/test-rg/providers/Microsoft\.Network/networkSecurityGroups/nsg-subnet2$';
            $filteredResult.properties.subnets[2].properties.routeTable.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/test-rg/providers/Microsoft\.Network/routeTables/route-subnet2$';
        }
    }

    Context 'With -ResourceGroup object' {
        It 'From hashtable' {
            $exportParams = @{
                TemplateFile  = $templatePath
                ParameterFile = $parametersPath
                ResourceGroup = @{
                    Location = 'custom';
                }
            }
            $result = Export-AzRuleTemplateData @exportParams -PassThru;
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 11;
            $result[1].location | Should -Be 'Custom';
        }
    }

    Context 'With Export-AzTemplateRuleData alias' {
        It 'Returns warning' {
            $outputFile = Join-Path -Path $outputPath -ChildPath 'template-with-defaults.json'
            $exportParams = @{
                TemplateFile  = $templatePath
                ParameterFile = $parametersPath
                OutputPath    = $outputFile
            }
            $Null = Export-AzTemplateRuleData @exportParams -WarningAction SilentlyContinue -WarningVariable warnings;
            $warningMessages = @($warnings);
            $warningMessages.Length | Should -Be 1;
        }
    }
}

#endregion Export-AzRuleTemplateData

#region Get-AzRuleTemplateLink

Describe 'Get-AzRuleTemplateLink' -Tag 'Cmdlet', 'Get-AzRuleTemplateLink' {
    BeforeAll {
        # Setup structure for scanning parameter files
        $templateScanPath = Join-Path -Path $outputPath -ChildPath 'templates/';
        $examplePath = Join-Path -Path $outputPath -ChildPath 'templates/example/';
        $Null = New-Item -Path $examplePath -ItemType Directory -Force;
        $Null = Copy-Item -Path (Join-Path -Path $here -ChildPath 'Resources.Parameters*.json') -Destination $templateScanPath -Force;
        $Null = Copy-Item -Path (Join-Path -Path $here -ChildPath 'Resources.Template*.json') -Destination $templateScanPath -Force;
        $Null = Copy-Item -Path (Join-Path -Path $here -ChildPath 'Resources.Parameters*.json') -Destination $examplePath -Force;
        $Null = Copy-Item -Path (Join-Path -Path $here -ChildPath 'Resources.Template*.json') -Destination $examplePath -Force;
    }

    Context 'With defaults' {
        It 'Exports template' {
            $getParams = @{
                Path      = $templateScanPath
                InputPath = Join-Path -Path $templateScanPath -ChildPath 'Resources.Parameters*.json'
            }

            # Get files in specific path
            $result = @(Get-AzRuleTemplateLink @getParams);
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 2;
            $result.ParameterFile | Should -BeIn @(
                (Join-Path -Path $templateScanPath -ChildPath 'Resources.Parameters.json')
                (Join-Path -Path $templateScanPath -ChildPath 'Resources.Parameters2.json')
            );
            @($result | Where-Object { $_.Metadata['additional'] -eq 'metadata' }).Length | Should -Be 1;

            # Get Resources.Parameters.json or Resources.Parameters2.json files in shallow path
            $result = @(Get-AzRuleTemplateLink -Path $templateScanPath -InputPath './Resources.Parameters?.json');
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 2;

            # Get Resources.Parameters.json or Resources.Parameters2.json files in recursive path
            $getParams['InputPath'] = 'Resources.Parameters*.json';
            $result = @(Get-AzRuleTemplateLink @getParams);
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 4;

            # Get Resources.Parameters.json files in recursive path
            $result = @(Get-AzRuleTemplateLink -Path $templateScanPath -f '*.Parameters.json');
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 2;
            $result.ParameterFile | Should -BeIn @(
                (Join-Path -Path $templateScanPath -ChildPath 'Resources.Parameters.json')
                (Join-Path -Path $examplePath -ChildPath 'Resources.Parameters.json')
            );

            # Reads subscriptionParameters.json
            $result = @(Get-AzRuleTemplateLink -Path $here -InputPath './Resources.Subscription.Parameters.json');
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 1;
        }

        It 'Handles exceptions' {
            $getParams = @{
                InputPath = Join-Path -Path $here -ChildPath 'Resources.ParameterFile.Fail.json'
            }

            # Non-relative path
            $Null = Get-AzRuleTemplateLink @getParams -ErrorVariable errorOut -ErrorAction SilentlyContinue;
            $errorOut[0].Exception.Message | Should -BeLike "Unable to find template referenced within parameter file '*'.";

            # File does not exist
            $getParams['InputPath'] = Join-Path -Path $here -ChildPath 'Resources.ParameterFile.Fail2.json';
            $Null = Get-AzRuleTemplateLink @getParams -ErrorVariable errorOut -ErrorAction SilentlyContinue;
            $errorOut[0].Exception.Message | Should -BeLike "Unable to find template referenced within parameter file '*'.";

            # No metadata property
            $getParams['InputPath'] = Join-Path -Path $here -ChildPath 'Resources.ParameterFile.Fail3.json';
            $Null = Get-AzRuleTemplateLink @getParams -ErrorVariable errorOut -ErrorAction SilentlyContinue;
            $errorOut[0].Exception.Message | Should -BeLike "The parameter file '*' does not contain a metadata property.";

            # metadata.template property not set
            $getParams['InputPath'] = Join-Path -Path $here -ChildPath 'Resources.ParameterFile.Fail4.json';
            $Null = Get-AzRuleTemplateLink @getParams -ErrorVariable errorOut -ErrorAction SilentlyContinue;
            $errorOut[0].Exception.Message | Should -BeLike "The parameter file '*' does not reference a linked template.";
        }
    }
}

#endregion Get-AzRuleTemplateLink

#region Export-AzPolicyAssignmentData

Describe 'Export-AzPolicyAssignmentData' -Tag 'Cmdlet', 'Export-AzPolicyAssignmentData' {
    Context 'With Defaults' {
        BeforeAll {
            Mock -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith ${function:MockSingleSubscription};

            Mock -CommandName 'Get-AzPolicyAssignment' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith {
                return @(
                    [PSCustomObject]@{
                        Location           = 'eastus'
                        Name               = '000000000000000000000000'
                        ResourceId         = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/PolicyRG/providers/Microsoft.Authorization/policyAssign 
                    ments/000000000000000000000000'
                        ResourceName       = '000000000000000000000000'
                        ResourceType       = 'Microsoft.Authorization/policyAssignments'
                        SubscriptionId     = '00000000-0000-0000-0000-000000000000'
                        PolicyAssignmentId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/PolicyRG/providers/Microsoft.Authorization/policyAssign 
                    ments/000000000000000000000000'
                        Properties         = [PSCustomObject]@{
                            Scope                 = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/PolicyRG'
                            NotScopes             = [PSCustomObject]@{}
                            DisplayName           = 'Latest TLS version should be used in your Function App'
                            Description           = 'Upgrade to the latest TLS version'
                            EnforcementMode       = 'Default'
                            PolicyDefinitionId    = '/providers/Microsoft.Authorization/policyDefinitions/00000000-0000-0000-0000-000000000000'
                            Parameters            = [PSCustomObject]@{}
                            NonComplianceMessages = [PSCustomObject]@{}
                        }
                    }
                    [PSCustomObject]@{
                        Location           = 'eastus'
                        Name               = '000000000000000000000001'
                        ResourceId         = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/PolicyRG/providers/Microsoft.Authorization/policyAssign 
                    ments/000000000000000000000001'
                        ResourceName       = '000000000000000000000001'
                        ResourceType       = 'Microsoft.Authorization/policyAssignments'
                        SubscriptionId     = '00000000-0000-0000-0000-000000000000'
                        PolicyAssignmentId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/PolicyRG/providers/Microsoft.Authorization/policyAssign 
                    ments/000000000000000000000000'
                        Properties         = [PSCustomObject]@{
                            Scope                 = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/PolicyRG'
                            NotScopes             = [PSCustomObject]@{}
                            DisplayName           = 'Upgrade to the latest TLS version for PaaS services'
                            Description           = 'Upgrade to the latest TLS version for PaaS services'
                            EnforcementMode       = 'Default'
                            PolicyDefinitionId    = '/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/policySetDefinitions/000000000000 
                            4eada7d6fb41'
                            Parameters            = [PSCustomObject]@{}
                            NonComplianceMessages = [PSCustomObject]@{}
                        }
                    }
                )
            }

            Mock -CommandName 'Get-AzPolicyDefinition' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith {
                return [PSCustomObject]@{
                    Name               = '00000000-0000-0000-0000-000000000000'
                    ResourceId         = '/providers/Microsoft.Authorization/policyDefinitions/00000000-0000-0000-0000-000000000000'
                    ResourceName       = '00000000-0000-0000-0000-000000000000'
                    ResourceType       = 'Microsoft.Authorization/policyDefinitions'
                    PolicyDefinitionId = '/providers/Microsoft.Authorization/policyDefinitions/00000000-0000-0000-0000-000000000000'
                    Properties         = [PSCustomObject]@{
                        Description = 'Upgrade to the latest TLS version'
                        DisplayName = 'Latest TLS version should be used in your Function App'
                        Metadata    = [PSCustomObject]@{}
                        Mode        = 'Indexed'
                        Parameters  = [PSCustomObject]@{}
                        PolicyRule  = [PSCustomObject]@{}
                        PolicyType  = 'BuiltIn'
                    }
                }
            }

            Mock -CommandName 'Get-AzPolicySetDefinition' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith {
                return [PSCustomObject]@{
                    Name               = '00000000-0000-0000-0000-000000000000'
                    ResourceId         = '/providers/Microsoft.Authorization/policySetDefinitions/00000000-0000-0000-0000-000000000000'
                    ResourceName       = '00000000-0000-0000-0000-000000000000'
                    ResourceType       = 'Microsoft.Authorization/policySetDefinitions'
                    PolicyDefinitionId = '/providers/Microsoft.Authorization/policySetDefinitions/00000000-0000-0000-0000-000000000000'
                    Properties         = [PSCustomObject]@{
                        Description       = 'Upgrade to the latest TLS version for PaaS services'
                        DisplayName       = 'Upgrade to the latest TLS version for PaaS services'
                        Metadata          = [PSCustomObject]@{}
                        Mode              = 'Indexed'
                        Parameters        = [PSCustomObject]@{}
                        PolicyDefinitions = @(
                            [PSCustomObject]@{
                                policyDefinitionReferenceId = 'FunctionAppTLS'
                                policyDefinitionId          = '/providers/Microsoft.Authorization/policyDefinitions/00000000-0000-0000-0000-000000000000'
                            }
                        )
                        PolicyType        = 'Custom'
                    }
                }
            }
        }

        It 'Exports assignments' {
            $result = @(Export-AzPolicyAssignmentData -OutputPath $outputPath);

            Assert-VerifiableMock;

            Assert-MockCalled -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Times 1;
            Assert-MockCalled -CommandName 'Get-AzPolicyAssignment' -ModuleName 'PSRule.Rules.Azure' -Times 1;
            Assert-MockCalled -CommandName 'Get-AzPolicyDefinition' -ModuleName 'PSRule.Rules.Azure' -Times 1;
            Assert-MockCalled -CommandName 'Get-AzPolicySetDefinition' -ModuleName 'PSRule.Rules.Azure' -Times 1;

            $result.Length | Should -Be 1;
            $result | Should -BeOfType System.IO.FileInfo;

            $data = Get-Content -Path $result.FullName | ConvertFrom-Json;
            $data -is [System.Array] | Should -Be $True;
            $data.Length | Should -Be 2;
            $data.Name | Should -BeIn '000000000000000000000000', '000000000000000000000001';
        }

        AfterAll {
            Remove-Item -Path (Join-Path -Path $outputPath -ChildPath '00000000-0000-0000-0000-000000000001.assignment.json') -Force;
        }
    }
}

#endregion Export-AzPolicyAssignmentData

#region Export-AzPolicyAssignmentRuleData

Describe 'Export-AzPolicyAssignmentRuleData' -Tag 'Cmdlet', 'Export-AzPolicyAssignmentRuleData' {
    BeforeAll {
        $emittedJsonRulesDataFile = Join-Path -Path $here -ChildPath 'emittedJsonRulesData.jsonc';
        $jsonRulesData = ((Get-Content -Path $emittedJsonRulesDataFile) -replace '^\s*//.*') | ConvertFrom-Json;
    }

    BeforeDiscovery {
        $here = (Resolve-Path $PSScriptRoot).Path;
    }

    It "Emit JSON rules from '<AssignmentFile>'" -TestCases @(
        @{
            Name           = 'test'
            Index          = 0
            AssignmentFile = (Join-Path -Path $here -ChildPath 'test.assignment.json')
        }
        @{
            Name           = 'test2'
            Index          = 1
            AssignmentFile = (Join-Path -Path $here -ChildPath 'test2.assignment.json')
        }
        @{
            Name           = 'test3'
            Index          = 2
            AssignmentFile = (Join-Path -Path $here -ChildPath 'test3.assignment.json')
        }
    ) {
        param($Name, $Index, $AssignmentFile)
        $result = @(Export-AzPolicyAssignmentRuleData -Name $Name -AssignmentFile $AssignmentFile -OutputPath $outputPath);
        $result.Length | Should -Be 1;
        $result | Should -BeOfType System.IO.FileInfo;
        $filename = Split-Path -Path $result.FullName -Leaf;
        $filename | Should -BeExactly "definitions-$Name.Rule.jsonc";
        $resultJson = ((Get-Content -Path $result.FullName) -replace '^\s*//.*') | ConvertFrom-Json;
        $compressedResult = $resultJson | ConvertTo-Json -Depth 100 -Compress;
        $compressedExpected = $jsonRulesData[$Index] | ConvertTo-Json -Depth 100 -Compress;
        $compressedResult | Should -BeExactly $compressedExpected;
    }
}

#endregion Export-AzPolicyAssignmentRuleData

#region Get-AzPolicyAssignmentDataSource

Describe 'Get-AzPolicyAssignmentDataSource' -Tag 'Cmdlet', 'Get-AzPolicyAssignmentDataSource' {
    BeforeAll {
        $emittedJsonRulesDataFile = Join-Path -Path $here -ChildPath 'emittedJsonRulesData.jsonc';
        $jsonRulesData = ((Get-Content -Path $emittedJsonRulesDataFile) -replace '^\s*//.*') | ConvertFrom-Json;
    }

    It 'Get assignment sources from current working directory' {
        $sources = Get-AzPolicyAssignmentDataSource | Sort-Object -Property AssignmentFile
        $sources.Length | Should -Be 3;
        $sources[0].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test.assignment.json');
        $sources[1].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test2.assignment.json');
        $sources[2].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test3.assignment.json');
    }

    It 'Get assignment sources from tests folder' {
        $sources = Get-AzPolicyAssignmentDataSource -Path $here | Sort-Object -Property AssignmentFile;
        $sources.Length | Should -Be 3;
        $sources[0].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test.assignment.json');
        $sources[1].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test2.assignment.json');
        $sources[2].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test3.assignment.json');
    }

    It 'Pipe to Export-AzPolicyAssignmentRuleData and generate JSON rules' {
        $result = @(Get-AzPolicyAssignmentDataSource | Sort-Object -Property AssignmentFile | Export-AzPolicyAssignmentRuleData -Name 'tests' -OutputPath $outputPath);
        $result.Length | Should -Be 1;
        $result | Should -BeOfType System.IO.FileInfo;
        $filename = Split-Path -Path $result.FullName -Leaf;
        $filename | Should -BeExactly "definitions-tests.Rule.jsonc";
        $resultJson = ((Get-Content -Path $result.FullName) -replace '^\s*//.*') | ConvertFrom-Json;
        $compressedResult = $resultJson | ConvertTo-Json -Depth 100 -Compress;
        $compressedExpected = $jsonRulesData | ConvertTo-Json -Depth 100 -Compress;
        $compressedResult | Should -BeExactly $compressedExpected;
    }
}

#endregion Get-AzPolicyAssignmentDataSource

#region PSRule.Rules.Azure.psm1 Private Functions

Describe 'VisitAKSCluster' {
    BeforeAll {
        Mock -CommandName 'GetResourceById' -ModuleName 'PSRule.Rules.Azure' -MockWith {
            return @(
                [PSCustomObject]@{
                    Name       = 'Resource1'
                    ResourceID = 'subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-A/subnets/subnet-A'
                }
                [PSCustomObject]@{
                    Name       = 'Resource2'
                    ResourceID = 'subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-A/subnets/subnet-B'
                }
            )
        };

        Mock -CommandName 'Get-AzResource' -ModuleName 'PSRule.Rules.Azure' -MockWith {
            return @(
                [PSCustomObject]@{
                    Name         = 'Resource3'
                    ResourceType = 'microsoft.insights/diagnosticSettings'
                    Id           = '/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/k8s-aks-cluster-rg/providers/microsoft.containerservice/managedclusters/k8s-aks-cluster/providers/microsoft.insights/diagnosticSettings/metrics'
                    ResourceId   = '/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/k8s-aks-cluster-rg/providers/microsoft.containerservice/managedclusters/k8s-aks-cluster/providers/microsoft.insights/diagnosticSettings/metrics'
                    Properties   = [PSCustomObject]@{
                        metrics = @()
                        logs    = @()
                    }
                }
            )
        }
    }

    Context 'Network Plugin' {
        It 'Given AzureCNI plugin it returns resource with VNET subnet IDs attached as sub resource' {
            InModuleScope -ModuleName 'PSRule.Rules.Azure' {
                $resource = [PSCustomObject]@{
                    Name              = 'akscluster'
                    ResourceGroupName = 'akscluster-rg'
                    Properties        = [PSCustomObject]@{
                        agentPoolProfiles = @(
                            [PSCustomObject]@{
                                name         = 'agentpool1'
                                vnetSubnetId = 'subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-A/subnets/subnet-A'
                            }
                            [PSCustomObject]@{
                                name         = 'agentpool2'
                                vnetSubnetId = 'subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-A/subnets/subnet-B'
                            }
                        )
                        networkProfile    = [PSCustomObject]@{
                            networkPlugin = 'azure'
                        }
                    }
                };

                $context = New-MockObject -Type Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext;
                $clusterResource = $resource | VisitAKSCluster -Context $context;

                $clusterResource.resources | Should -Not -BeNullOrEmpty;

                Assert-MockCalled -CommandName 'GetResourceById' -Times 2;
                Assert-MockCalled -CommandName 'Get-AzResource' -Times 1;

                $clusterResource.resources[0].Name | Should -BeExactly 'Resource1';
                $clusterResource.resources[0].ResourceID | Should -BeExactly 'subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-A/subnets/subnet-A';

                $clusterResource.resources[1].Name | Should -BeExactly 'Resource2';
                $clusterResource.resources[1].ResourceID | Should -BeExactly 'subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-A/subnets/subnet-B';

                $clusterResource.resources[4].Name | Should -BeExactly 'Resource3';
                $clusterResource.resources[4].ResourceType | Should -Be 'microsoft.insights/diagnosticSettings';
                $clusterResource.resources[4].ResourceID | Should -Be '/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/k8s-aks-cluster-rg/providers/microsoft.containerservice/managedclusters/k8s-aks-cluster/providers/microsoft.insights/diagnosticSettings/metrics'
                $clusterResource.resources[4].Properties.metrics | Should -BeNullOrEmpty;
                $clusterResource.resources[4].Properties.logs | Should -BeNullOrEmpty;
            }
        }

        It 'Given kubelet plugin it returns resource with empty sub resource' {
            InModuleScope -ModuleName 'PSRule.Rules.Azure' {
                $resource = [PSCustomObject]@{
                    Name              = 'akscluster'
                    ResourceGroupName = 'akscluster-rg'
                    Properties        = [PSCustomObject]@{
                        agentPoolProfiles = @(
                            [PSCustomObject]@{
                                name = 'agentpool1'
                            }
                            [PSCustomObject]@{
                                name = 'agentpool2'
                            }
                        )
                        networkProfile    = [PSCustomObject]@{
                            networkPlugin = 'kubelet'
                        }
                    }
                };

                $context = New-MockObject -Type Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext;
                $clusterResource = $resource | VisitAKSCluster -Context $context;

                Assert-MockCalled -CommandName 'GetResourceById' -Times 0;
                Assert-MockCalled -CommandName 'Get-AzResource' -Times 1;

                $clusterResource.resources[0].Name | Should -BeExactly 'Resource3';
                $clusterResource.resources[0].ResourceType | Should -Be 'microsoft.insights/diagnosticSettings';
                $clusterResource.resources[0].ResourceID | Should -Be '/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/k8s-aks-cluster-rg/providers/microsoft.containerservice/managedclusters/k8s-aks-cluster/providers/microsoft.insights/diagnosticSettings/metrics'
                $clusterResource.resources[0].Properties.metrics | Should -BeNullOrEmpty;
                $clusterResource.resources[0].Properties.logs | Should -BeNullOrEmpty;
            }
        }
    }
}

Describe 'VisitPublicIP' -Tag 'Cmdlet', 'Export-AzRuleData', 'VisitPublicIP' {
    Context "Availability Zones" {
        It "Non-empty zones are added to Public IP resource" {
            InModuleScope -ModuleName 'PSRule.Rules.Azure' {
                $resource = [PSCustomObject]@{
                    Name              = 'Resource1'
                    ResourceGroupName = 'lb-rg'
                    ResourceID        = '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/lb-rg/providers/Microsoft.Network/publicIPAddresses/test-ip'
                };

                Mock -CommandName 'Invoke-AzRestMethod' -MockWith {
                    return [PSCustomObject]@{
                        Content = [PSCustomObject]@{
                            Name              = 'Resource1'
                            ResourceGroupName = 'lb-rg'
                            ResourceID        = '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/lb-rg/providers/Microsoft.Network/publicIPAddresses/test-ip'
                            Zones             = @("1", "2", "3")
                        } | ConvertTo-Json
                    }
                };

                $context = New-MockObject -Type Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext;
                $publicIpResource = $resource | VisitPublicIP -Context $context;

                Assert-MockCalled -CommandName 'Invoke-AzRestMethod' -Times 1;

                $publicIpResource[0].Name | Should -Be 'Resource1';
                $publicIpResource[0].ResourceGroupName | Should -Be 'lb-rg';
                $publicIpResource[0].ResourceID | Should -Be '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/lb-rg/providers/Microsoft.Network/publicIPAddresses/test-ip';
                $publicIpResource[0].zones | Should -Be @("1", "2", "3");
            }
        }

        It 'Empty zones are set to null in Public IP resource' {
            InModuleScope -ModuleName 'PSRule.Rules.Azure' {
                $resource = [PSCustomObject]@{
                    Name              = 'Resource1'
                    ResourceGroupName = 'lb-rg'
                    ResourceID        = '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/lb-rg/providers/Microsoft.Network/publicIPAddresses/test-ip'
                };

                Mock -CommandName 'Invoke-AzRestMethod' -MockWith {
                    return [PSCustomObject]@{
                        Content = [PSCustomObject]@{
                            Name              = 'Resource1'
                            ResourceGroupName = 'lb-rg'
                            ResourceID        = '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/lb-rg/providers/Microsoft.Network/publicIPAddresses/test-ip'
                            Zones             = @()
                        } | ConvertTo-Json
                    }
                };

                $context = New-MockObject -Type Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext;
                $publicIpResource = $resource | VisitPublicIP -Context $context;

                Assert-MockCalled -CommandName 'Invoke-AzRestMethod' -Times 1;

                $publicIpResource[0].Name | Should -Be 'Resource1';
                $publicIpResource[0].ResourceGroupName | Should -Be 'lb-rg';
                $publicIpResource[0].ResourceID | Should -Be '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/lb-rg/providers/Microsoft.Network/publicIPAddresses/test-ip';
                $publicIpResource[0].zones | Should -BeNullOrEmpty;
            }
        }

        It 'No zones are set on Public IP resource' {
            InModuleScope -ModuleName 'PSRule.Rules.Azure' {
                $resource = [PSCustomObject]@{
                    Name              = 'Resource1'
                    ResourceGroupName = 'lb-rg'
                    ResourceID        = '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/lb-rg/providers/Microsoft.Network/publicIPAddresses/test-ip'
                };

                Mock -CommandName 'Invoke-AzRestMethod' -MockWith {
                    return [PSCustomObject]@{
                        Content = [PSCustomObject]@{
                            Name              = 'Resource1'
                            ResourceGroupName = 'lb-rg'
                            ResourceID        = '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/lb-rg/providers/Microsoft.Network/publicIPAddresses/test-ip'
                        } | ConvertTo-Json
                    }
                };

                $context = New-MockObject -Type Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext;
                $publicIpResource = $resource | VisitPublicIP -Context $context;

                Assert-MockCalled -CommandName 'Invoke-AzRestMethod' -Times 1;

                $publicIpResource[0].Name | Should -Be 'Resource1';
                $publicIpResource[0].ResourceGroupName | Should -Be 'lb-rg';
                $publicIpResource[0].ResourceID | Should -Be '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/lb-rg/providers/Microsoft.Network/publicIPAddresses/test-ip';
            }
        }
    }
}

#endregion

#region Azure.Common.Rule.ps1 Functions
Describe 'GetAvailabilityZone' {
    It "Given array of zones and '<location>' it returns '<expected>'" -TestCases @(
        @{ 
            Zones    = @(
                [PSCustomObject]@{
                    Location = "South Africa North"
                    Zones    = @()
                }
                [PSCustomObject]@{
                    Location = "Central US"
                    Zones    = @("1", "2", "3")
                }
            )
            Location = "Central US"
            Expected = @("1", "2", "3")
        }
        @{ 
            Zones    = @(
                [PSCustomObject]@{
                    Location = "South Africa North"
                    Zones    = @()
                }
                [PSCustomObject]@{
                    Location = "Central US"
                    Zones    = @("1", "2", "3")
                }
            )
            Location = "South Africa North"
            Expected = @()
        }
        @{ 
            Zones    = @(
                [PSCustomObject]@{
                    Location = "South Africa North"
                    Zones    = @()
                }
                [PSCustomObject]@{
                    Location = "Central US"
                    Zones    = @("1", "2", "3")
                }
            )
            Location = "Australia East"
            Expected = $null
        }
    ) {
        param($Zones, $Location, $Expected)
        GetAvailabilityZone -Location $Location -Zone $Zones | Should -Be $Expected;
    }
}

Describe 'PrependConfigurationZoneWithProviderZone' {
    It 'Given non-empty configuration zones and provider zones it prepends configuration zones in front of provider zones' {
        $configurationZones = @(
            [PSCustomObject]@{
                Location = "Australia Southeast"
                Zones    = @("1", "2", "3")
            }
            [PSCustomObject]@{
                Location = "Australia Central"
                Zones    = @("1", "2", "3")
            }
        );
        
        $providerZones = @(
            [PSCustomObject]@{
                Location = "South Africa North"
                Zones    = @()
            }
            [PSCustomObject]@{
                Location = "Central US"
                Zones    = @("1", "2", "3")
            }
        )

        $merged = PrependConfigurationZoneWithProviderZone -ConfigurationZone $configurationZones -ProviderZone $providerZones;
        
        $merged[0].Location | Should -Be "Australia Southeast"
        $merged[0].Zones | Should -Be @("1", "2", "3")

        $merged[1].Location | Should -Be "Australia Central"
        $merged[1].Zones | Should -Be @("1", "2", "3")

        $merged[2].Location | Should -Be "South Africa North"
        $merged[2].Zones | Should -Be @()

        $merged[3].Location | Should -Be "Central US"
        $merged[3].Zones | Should -Be @("1", "2", "3")
    }

    It 'Given empty configuration zones and provider zones only provider zones are returned' {
        $configurationZones = @();
        
        $providerZones = @(
            [PSCustomObject]@{
                Location = "South Africa North"
                Zones    = @()
            }
            [PSCustomObject]@{
                Location = "Central US"
                Zones    = @("1", "2", "3")
            }
        )

        $merged = PrependConfigurationZoneWithProviderZone -ConfigurationZone $configurationZones -ProviderZone $providerZones;
        
        $merged[0].Location | Should -Be "South Africa North"
        $merged[0].Zones | Should -Be @()

        $merged[1].Location | Should -Be "Central US"
        $merged[1].Zones | Should -Be @("1", "2", "3")
    }
}

#endregion