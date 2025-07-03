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
            $result.Length | Should -Be 8;
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
            $result.Length | Should -Be 8;
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
            $result.Length | Should -Be 8;
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
            $result.Length | Should -Be 8;
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
            $result.Length | Should -Be 8;
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
            $result.Length | Should -Be 8;
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

#region Export-AzPolicyAssignmentRuleData

Describe 'Export-AzPolicyAssignmentRuleData' -Tag 'Cmdlet', 'Export-AzPolicyAssignmentRuleData', 'assignment' {
    BeforeAll {
        $emittedJsonRulesDataFile = Join-Path -Path $here -ChildPath 'emittedJsonRulesData.jsonc';
        $emittedJsonRulesPrefixDataFile = Join-Path -Path $here -ChildPath 'emittedJsonRulesPrefixData.jsonc';
        $jsonRulesData = ((Get-Content -Path $emittedJsonRulesDataFile) -replace '^\s*//.*') | ConvertFrom-Json;
        $jsonRulesPrefixData = ((Get-Content -Path $emittedJsonRulesPrefixDataFile) -replace '^\s*//.*') | ConvertFrom-Json;
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
        @{
            Name           = 'test4'
            Index          = 3
            AssignmentFile = (Join-Path -Path $here -ChildPath 'test4.assignment.json')
        },
        @{
            Name           = 'test5'
            Index          = 4
            AssignmentFile = (Join-Path -Path $here -ChildPath 'test5.assignment.json')
        },
        @{
            Name           = 'test6'
            Index          = 5
            AssignmentFile = (Join-Path -Path $here -ChildPath 'test6.assignment.json')
        },
        @{
            Name           = 'test7'
            Index          = 6
            AssignmentFile = (Join-Path -Path $here -ChildPath 'test7.assignment.json')
        },
        @{
            Name           = 'test8'
            Index          = 7
            AssignmentFile = (Join-Path -Path $here -ChildPath 'test8.assignment.json')
        },
        @{
            Name           = 'test9'
            Index          = 8
            AssignmentFile = (Join-Path -Path $here -ChildPath 'test9.assignment.json')
        },
        @{
            Name           = 'test10'
            Index          = 9
            AssignmentFile = (Join-Path -Path $here -ChildPath 'test10.assignment.json')
        },
        @{
            Name           = 'test11'
            Index          = 10
            AssignmentFile = (Join-Path -Path $here -ChildPath 'test11.assignment.json')
        }
    ) {
        param($Name, $Index, $AssignmentFile)
        $result = @(Export-AzPolicyAssignmentRuleData -Name $Name -AssignmentFile $AssignmentFile -OutputPath $outputPath);
        $result.Length | Should -Be 1;
        $result | Should -BeOfType System.IO.FileInfo;
        $filename = Split-Path -Path $result.FullName -Leaf;
        $filename | Should -BeExactly "definitions-$Name.Rule.jsonc";
        $resultJson = ((Get-Content -Path $result.FullName) -replace '^\s*//.*') | ConvertFrom-Json;
        $compressedResult = $resultJson[0] | ConvertTo-Json -Depth 100 -Compress;
        $compressedExpected = $jsonRulesData[$Index] | ConvertTo-Json -Depth 100 -Compress;
        $compressedResult | Should -BeExactly $compressedExpected;
    }

    It 'RulePrefix is overridden when specified' {
        $testFile = Join-Path -Path $here -ChildPath 'test12.assignment.json'
        $result = @(Export-AzPolicyAssignmentRuleData -Name 'test12' -AssignmentFile $testFile -OutputPath $outputPath -RulePrefix 'AzureCustomPrefix');
        $result.Length | Should -Be 1;
        $result | Should -BeOfType System.IO.FileInfo;
        $filename = Split-Path -Path $result.FullName -Leaf;
        $filename | Should -BeExactly "definitions-test12.Rule.jsonc";
        $resultJson = ((Get-Content -Path $result.FullName) -replace '^\s*//.*') | ConvertFrom-Json;
        $compressedResult = $resultJson[0] | ConvertTo-Json -Depth 100 -Compress;
        $compressedExpected = $jsonRulesPrefixData | ConvertTo-Json -Depth 100 -Compress;
        $compressedResult | Should -BeExactly $compressedExpected;
    }
}

#endregion Export-AzPolicyAssignmentRuleData

#region Get-AzPolicyAssignmentDataSource

Describe 'Get-AzPolicyAssignmentDataSource' -Tag 'Cmdlet', 'Get-AzPolicyAssignmentDataSource', 'assignment' {
    BeforeAll {
        $emittedJsonRulesDataFile = Join-Path -Path $here -ChildPath 'emittedJsonRulesData.jsonc';
        $jsonRulesData = ((Get-Content -Path $emittedJsonRulesDataFile) -replace '^\s*//.*') | ConvertFrom-Json;
    }

    It 'Get assignment sources from current working directory' {
        $sources = Get-AzPolicyAssignmentDataSource | Where-Object { $_.AssignmentFile -notlike "*Policy.assignment.json" } | Sort-Object { [int](Split-Path -Path $_.AssignmentFile -Leaf).Split('.')[0].TrimStart('test') }
        $sources.Length | Should -Be 12;
        $sources[0].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test.assignment.json');
        $sources[1].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test2.assignment.json');
        $sources[2].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test3.assignment.json');
        $sources[3].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test4.assignment.json');
        $sources[4].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test5.assignment.json');
        $sources[5].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test6.assignment.json');
        $sources[6].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test7.assignment.json');
        $sources[7].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test8.assignment.json');
        $sources[8].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test9.assignment.json');
        $sources[9].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test10.assignment.json');
        $sources[10].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test11.assignment.json');
        $sources[11].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test12.assignment.json');
    }

    It 'Get assignment sources from tests folder' {
        $sources = Get-AzPolicyAssignmentDataSource -Path $here | Where-Object { $_.AssignmentFile -notlike "*Policy.assignment.json" } | Sort-Object { [int](Split-Path -Path $_.AssignmentFile -Leaf).Split('.')[0].TrimStart('test') }
        $sources.Length | Should -Be 12;
        $sources[0].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test.assignment.json');
        $sources[1].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test2.assignment.json');
        $sources[2].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test3.assignment.json');
        $sources[3].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test4.assignment.json');
        $sources[4].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test5.assignment.json');
        $sources[5].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test6.assignment.json');
        $sources[6].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test7.assignment.json');
        $sources[7].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test8.assignment.json');
        $sources[8].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test9.assignment.json');
        $sources[9].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test10.assignment.json');
        $sources[10].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test11.assignment.json');
        $sources[11].AssignmentFile | Should -BeExactly (Join-Path -Path $here -ChildPath 'test12.assignment.json');
    }

    It 'Pipe to Export-AzPolicyAssignmentRuleData and generate JSON rules' {
        $result = @(Get-AzPolicyAssignmentDataSource | Where-Object { $_.AssignmentFile -notlike "*Policy.assignment.json" -and $_.AssignmentFile -notlike '*test12.assignment.json' } | Sort-Object { [int](Split-Path -Path $_.AssignmentFile -Leaf).Split('.')[0].TrimStart('test') } | Export-AzPolicyAssignmentRuleData -Name 'tests' -OutputPath $outputPath);
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
