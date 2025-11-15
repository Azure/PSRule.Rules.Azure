# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Azure SQL Managed Instance rules
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

Describe 'Azure.SQLMI' -Tag 'SQLMI' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.SQLMI.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.SQLMI.ManagedIdentity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.SQLMI.ManagedIdentity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'identity.type'

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-C', 'server-D';
        }

        It 'Azure.SQLMI.AADOnly' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.SQLMI.AADOnly' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-C', 'AzureADOnlyAuthentication-A';

            $ruleResult[0].Reason | Should -BeExactly "Azure AD-only authentication should be enabled for the service.";
            $ruleResult[1].Reason | Should -BeExactly "Azure AD-only authentication should be enabled for the service.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'server-B', 'server-D', 'AzureADOnlyAuthentication-B';
        }
        
        It 'Azure.SQLMI.AAD' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.SQLMI.AAD' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-C', 'ActiveDirectoryAdmin-A';

            $ruleResult[0].Reason | Should -BeExactly 'Path properties.administrators.administratorType: Does not exist.';
            $ruleResult[1].Reason | Should -BeExactly 'Path properties.administratorType: Is null or empty.', 'Path properties.login: Is null or empty.', 'Path properties.sid: Is null or empty.';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'server-B', 'server-D', 'ActiveDirectoryAdmin-B';
        }

        It 'Azure.SQLMI.MaintenanceWindow' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.SQLMI.MaintenanceWindow' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-A', 'server-B';

            $ruleResult[0].Reason | Should -BeExactly "The managed instance (server-A) should have a customer-controlled maintenance window configured.";
            $ruleResult[1].Reason | Should -BeExactly "The managed instance (server-B) should have a customer-controlled maintenance window configured.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'server-C', 'server-D';
        }
    }

    Context 'Resource name - Azure.SQLMI.Name' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name         = ''
                ResourceType = 'Microsoft.Sql/managedInstances'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'sqlserver1'
                'sqlserver-1'
                '1sqlserver'
            )

            $invalidNames = @(
                '-sqlserver1'
                'sqlserver1-'
                'sqlserver.1'
                'sqlserver_1'
                'SQLServer1'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.SQLMI.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.SQLMI.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'Resource naming format' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $option = New-PSRuleOption -Configuration @{
                'AZURE_SQL_MI_NAME_FORMAT' = '^sqlmi-'
            };

            $names = @('mi-001', 'sqlmi-001', 'SQLMI-001')
            $items = @($names | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.Sql/managedInstances'
                    }
                });

            $result = $items | Invoke-PSRule @invokeParams -Option $option
        }

        It 'Azure.SQLMI.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.SQLMI.Naming' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'mi-001', 'SQLMI-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'sqlmi-001';
        }
    }
}
