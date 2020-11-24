# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for module cmdlets
#

[CmdletBinding()]
param ()

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

#region Mocks

function MockContext {
    process {
        return @(
            (New-Object -TypeName Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext -ArgumentList @(
                [PSCustomObject]@{
                    Subscription = [PSCustomObject]@{
                        Id = '00000000-0000-0000-0000-000000000001'
                        Name = 'Test subscription 1'
                        State = 'Enabled'
                    }
                    Tenant = [PSCustomObject]@{
                        Id = '00000000-0000-0000-0000-000000000001'
                    }
                }
            )),
            (New-Object -TypeName Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext -ArgumentList @(
                [PSCustomObject]@{
                    Subscription = [PSCustomObject]@{
                        Id = '00000000-0000-0000-0000-000000000002'
                        Name = 'Test subscription 2'
                        State = 'Enabled'
                    }
                    Tenant = [PSCustomObject]@{
                        Id = '00000000-0000-0000-0000-000000000002'
                    }
                }
            ))
            (New-Object -TypeName Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext -ArgumentList @(
                [PSCustomObject]@{
                    Subscription = [PSCustomObject]@{
                        Id = '00000000-0000-0000-0000-000000000003'
                        Name = 'Test subscription 3'
                        State = 'Enabled'
                    }
                    Tenant = [PSCustomObject]@{
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
                        Id = '00000000-0000-0000-0000-000000000001'
                        Name = 'Test subscription 1'
                        State = 'Enabled'
                    }
                    Tenant = [PSCustomObject]@{
                        Id = '00000000-0000-0000-0000-000000000001'
                    }
                }
            ))
        )
    }
}

#endregion Mocks

#region Export-AzRuleData

Describe 'Export-AzRuleData' -Tag 'Cmdlet','Export-AzRuleData' {
    Context 'With defaults' {
        Mock -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith ${function:MockContext};
        Mock -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith {
            return @(
                [PSCustomObject]@{
                    Name = 'Resource1'
                    ResourceType = ''
                }
                [PSCustomObject]@{
                    Name = 'Resource2'
                    ResourceType = ''
                }
            )
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
        Mock -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -MockWith ${function:MockContext};
        Mock -CommandName 'GetAzureResource' -ModuleName 'PSRule.Rules.Azure' -MockWith {
            return @(
                [PSCustomObject]@{
                    Name = 'Resource1'
                    ResourceGroupName = 'rg-test-1'
                    ResourceType = ''
                }
                [PSCustomObject]@{
                    Name = 'Resource2'
                    ResourceGroupName = 'rg-test-2'
                    ResourceType = ''
                }
            )
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
        Mock -CommandName 'GetAzureContext' -ModuleName 'PSRule.Rules.Azure' -MockWith ${function:MockSingleSubscription};

        It 'Microsoft.Network/connections' {
            Mock -CommandName 'Get-AzResourceGroup' -ModuleName 'PSRule.Rules.Azure';
            Mock -CommandName 'Get-AzSubscription' -ModuleName 'PSRule.Rules.Azure';
            Mock -CommandName 'Get-AzResource' -ModuleName 'PSRule.Rules.Azure' -Verifiable -MockWith {
                return @(
                    [PSCustomObject]@{
                        Name = 'Resource1'
                        ResourceType = 'Microsoft.Network/connections'
                        Id = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/connections/cn001'
                        ResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/connections/cn001'
                        Properties = [PSCustomObject]@{ sharedKey = 'test123' }
                    }
                    [PSCustomObject]@{
                        Name = 'Resource2'
                        ResourceType = 'Microsoft.Network/connections'
                        Id = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/connections/cn002'
                        ResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/connections/cn002'
                        Properties = [PSCustomObject]@{ dummy = 'value' }
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
                        Name = 'Resource1'
                        ResourceType = 'Microsoft.Storage/storageAccounts'
                        Kind = 'StorageV2'
                        Id = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/sa001'
                        ResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/sa001'
                    }
                    [PSCustomObject]@{
                        Name = 'Resource2'
                        ResourceType = 'Microsoft.Storage/storageAccounts'
                        Kind = 'FileServices'
                        Id = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/sa002'
                        ResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/sa002'
                    }
                )
            }
            $Null = @(Export-AzRuleData -OutputPath $outputPath);
            Assert-MockCalled -CommandName 'GetSubResource' -ModuleName 'PSRule.Rules.Azure' -Times 1;
        }
    }
}

#endregion Export-AzRuleData

#region Export-AzTemplateRuleData

Describe 'Export-AzTemplateRuleData' -Tag 'Cmdlet','Export-AzTemplateRuleData' {
    $templatePath = Join-Path -Path $here -ChildPath 'Resources.Template.json';
    $parametersPath = Join-Path -Path $here -ChildPath 'Resources.Parameters.json';

    Context 'With defaults' {
        It 'Exports template' {
            $outputFile = Join-Path -Path $outputPath -ChildPath 'template-with-defaults.json'
            $exportParams = @{
                TemplateFile = $templatePath
                ParameterFile = $parametersPath
                OutputPath = $outputFile
            }
            $Null = Export-AzTemplateRuleData @exportParams;
            $result = Get-Content -Path $outputFile -Raw | ConvertFrom-Json;
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 9;
            $result[0].name | Should -Be 'vnet-001';
            $result[0].properties.addressSpace.addressPrefixes | Should -Be "10.1.0.0/24";
            $result[0].properties.subnets.Length | Should -Be 3;
            $result[0].properties.subnets[0].name | Should -Be 'GatewaySubnet';
            $result[0].properties.subnets[0].properties.addressPrefix | Should -Be '10.1.0.0/27';
            $result[0].properties.subnets[2].name | Should -Be 'subnet2';
            $result[0].properties.subnets[2].properties.addressPrefix | Should -Be '10.1.0.64/28';
            $result[0].properties.subnets[2].properties.networkSecurityGroup.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/networkSecurityGroups/nsg-subnet2$';
            $result[0].properties.subnets[2].properties.routeTable.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/routeTables/route-subnet2$';
        }

        It 'Returns file not found' {
            $exportParams = @{
                PassThru = $True
            }

            # Invalid template file
            $exportParams['TemplateFile'] = 'notafile.json';
            $exportParams['ParameterFile'] = $parametersPath;
            $errorOut = { $Null = Export-AzTemplateRuleData @exportParams -ErrorVariable exportErrors -ErrorAction SilentlyContinue; $exportErrors; } | Should -Throw -PassThru;
            $errorOut[0].Exception.Message | Should -BeLike "Unable to find the specified template file '*'.";

            # Invalid parameter file
            $exportParams['TemplateFile'] = $templatePath;
            $exportParams['ParameterFile'] = 'notafile.json';
            $errorOut = { $Null = Export-AzTemplateRuleData @exportParams -ErrorVariable exportErrors -ErrorAction SilentlyContinue; $exportErrors; } | Should -Throw -PassThru;
            $errorOut[0].Exception.Message | Should -BeLike "Unable to find the specified parameter file '*'.";
        }
    }

    Context 'With -PassThru' {
        It 'Exports template' {
            $exportParams = @{
                TemplateFile = $templatePath
                ParameterFile = $parametersPath
            }
            $result = @(Export-AzTemplateRuleData @exportParams -PassThru);
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 9;
            $result[0].name | Should -Be 'vnet-001';
            $result[0].properties.subnets.Length | Should -Be 3;
            $result[0].properties.subnets[0].name | Should -Be 'GatewaySubnet';
            $result[0].properties.subnets[0].properties.addressPrefix | Should -Be '10.1.0.0/27';
            $result[0].properties.subnets[2].name | Should -Be 'subnet2';
            $result[0].properties.subnets[2].properties.addressPrefix | Should -Be '10.1.0.64/28';
            $result[0].properties.subnets[2].properties.networkSecurityGroup.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/networkSecurityGroups/nsg-subnet2$';
            $result[0].properties.subnets[2].properties.routeTable.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/routeTables/route-subnet2$';
        }
    }

    Context 'With -Subscription' {
        Mock -CommandName 'GetSubscription' -ModuleName 'PSRule.Rules.Azure' -MockWith {
            return [PSCustomObject]@{
                SubscriptionId = '00000000-0000-0000-0000-000000000000'
                TenantId = '00000000-0000-0000-0000-000000000000'
                Name = 'test-sub'
            }
        }
        It 'Exports template' {
            $exportParams = @{
                TemplateFile = $templatePath
                ParameterFile = $parametersPath
                Subscription = 'test-sub'
            }
            $result = Export-AzTemplateRuleData @exportParams -PassThru;
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 9;
            $result[0].properties.subnets.Length | Should -Be 3;
            $result[0].properties.subnets[2].properties.networkSecurityGroup.id | Should -Match '^/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/networkSecurityGroups/nsg-subnet2$';
            $result[0].properties.subnets[2].properties.routeTable.id | Should -Match '^/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/[\w\{\}\-\.]{1,}/providers/Microsoft\.Network/routeTables/route-subnet2$';
        }
    }

    Context 'With -ResourceGroup' {
        Mock -CommandName 'GetResourceGroup' -ModuleName 'PSRule.Rules.Azure' -MockWith {
            return [PSCustomObject]@{
                ResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg'
                ResourceGroupName = 'test-rg'
                Location = 'region'
                ManagedBy = 'testuser'
                Tags = @{
                    test = 'true'
                }
            }
        }
        It 'Exports template' {
            $exportParams = @{
                TemplateFile = $templatePath
                ParameterFile = $parametersPath
                ResourceGroupName = 'test-rg'
            }
            $result = Export-AzTemplateRuleData @exportParams -PassThru;
            $result | Should -Not -BeNullOrEmpty;
            $result.Length | Should -Be 9;
            $result[0].properties.subnets.Length | Should -Be 3;
            $result[0].properties.subnets[2].properties.networkSecurityGroup.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/test-rg/providers/Microsoft\.Network/networkSecurityGroups/nsg-subnet2$';
            $result[0].properties.subnets[2].properties.routeTable.id | Should -Match '^/subscriptions/[\w\{\}\-\.]{1,}/resourceGroups/test-rg/providers/Microsoft\.Network/routeTables/route-subnet2$';
        }
    }
}

#endregion Export-AzTemplateRuleData

#region Get-AzRuleTemplateLink

Describe 'Get-AzRuleTemplateLink' -Tag 'Cmdlet', 'Get-AzRuleTemplateLink' {
    # Setup structure for scanning parameter files
    $templateScanPath = Join-Path -Path $outputPath -ChildPath 'templates/';
    $examplePath = Join-Path -Path $outputPath -ChildPath 'templates/example/';
    $Null = New-Item -Path $examplePath -ItemType Directory -Force;
    $Null = Copy-Item -Path (Join-Path -Path $here -ChildPath 'Resources.Parameters*.json') -Destination $templateScanPath -Force;
    $Null = Copy-Item -Path (Join-Path -Path $here -ChildPath 'Resources.Template*.json') -Destination $templateScanPath -Force;
    $Null = Copy-Item -Path (Join-Path -Path $here -ChildPath 'Resources.Parameters*.json') -Destination $examplePath -Force;
    $Null = Copy-Item -Path (Join-Path -Path $here -ChildPath 'Resources.Template*.json') -Destination $examplePath -Force;

    Context 'With defaults' {
        It 'Exports template' {
            $getParams = @{
                Path = $templateScanPath
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
