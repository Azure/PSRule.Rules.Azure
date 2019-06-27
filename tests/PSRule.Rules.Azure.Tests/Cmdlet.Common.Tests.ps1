#
# Unit tests for module cmdlets
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
$outputPath = Join-Path -Path $rootPath -ChildPath out/tests/PSRule.Rules.Azure.Tests/Cmdlet;
Remove-Item -Path $outputPath -Force -Recurse -Confirm:$False -ErrorAction Ignore;
$Null = New-Item -Path $outputPath -ItemType Directory -Force;

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

#endregion Mocks

#region Export-AzRuleData

Describe 'Export-AzRuleData' -Tag 'Cmdlet' {
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
}

#endregion Export-AzRuleData
