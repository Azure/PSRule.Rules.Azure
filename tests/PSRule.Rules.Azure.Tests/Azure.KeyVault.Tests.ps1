# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Key Vault rules
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

Describe 'Azure.KeyVault' -Tag 'KeyVault' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.KeyVault.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
        }

        It 'Azure.KeyVault.SoftDelete' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.SoftDelete' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'keyvault-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'keyvault-A', 'keyvault-C', 'keyvault-D', 'keyvault-E', 'keyvault-F', 'keyvault-G', 'keyvault-H';
        }

        It 'Azure.KeyVault.PurgeProtect' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.PurgeProtect' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'keyvault-B', 'keyvault-C';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'keyvault-A', 'keyvault-D', 'keyvault-E', 'keyvault-F', 'keyvault-G', 'keyvault-H';
        }

        It 'Azure.KeyVault.AccessPolicy' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.AccessPolicy' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'keyvault-B';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "One or more access policies grant all or purge permission.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'keyvault-A', 'keyvault-C', 'keyvault-D', 'keyvault-E', 'keyvault-F', 'keyvault-G', 'keyvault-H';
        }

        It 'Azure.KeyVault.Logs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.Logs' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'keyvault-B', 'keyvault-C', 'keyvault-D', 'keyvault-E', 'keyvault-G';

            $ruleResult[0].Reason | Should -BeExactly "Minimum one diagnostic setting should have (AuditEvent) configured or category group (audit, allLogs) configured.";
            $ruleResult[1].Reason | Should -BeExactly "Minimum one diagnostic setting should have (AuditEvent) configured or category group (audit, allLogs) configured.";
            $ruleResult[2].Reason | Should -BeExactly "Minimum one diagnostic setting should have (AuditEvent) configured or category group (audit, allLogs) configured.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'keyvault-A', 'keyvault-F', 'keyvault-H';
        }

        It 'Azure.KeyVault.AutoRotationPolicy' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.AutoRotationPolicy' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'keyvault-G', 'keyvault-H';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The key (key1) should enable a auto-rotation policy.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'keyvault-A', 'keyvault-B', 'keyvault-C', 'keyvault-D', 'keyvault-E', 'keyvault-F';
        }

        It 'Azure.KeyVault.Firewall' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.Firewall' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'keyvault-B', 'keyvault-C', 'keyvault-D', 'keyvault-E', 'keyvault-F', 'keyvault-G', 'keyvault-H';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'keyvault-A';
        }

        It 'Azure.KeyVault.RBAC' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.RBAC' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'keyvault-A', 'keyvault-B', 'keyvault-D', 'keyvault-E', 'keyvault-F', 'keyvault-G';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.enableRbacAuthorization'

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'keyvault-C', 'keyvault-H';
        }
    }

    Context 'Resource name - Azure.KeyVault.Name' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name         = ''
                ResourceType = 'Microsoft.KeyVault/vaults'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'Key-vault1'
            )

            $invalidNames = @(
                '_keyvault1'
                '-keyvault1'
                'keyvault.1'
                'key_vault1'
                'keyvault1-'
                '1keyvault'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.KeyVault.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.KeyVault.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'Resource name - Azure.KeyVault.SecretName' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name         = ''
                ResourceType = 'Microsoft.KeyVault/vaults/secrets'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'Secret-1'
                '-secret1'
            )

            $invalidNames = @(
                'secret.1'
                'secret_1'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.KeyVault.SecretName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.KeyVault.SecretName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'Resource name - Azure.KeyVault.KeyName' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name         = ''
                ResourceType = 'Microsoft.KeyVault/vaults/keys'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'Key-1'
                '-key1'
            )

            $invalidNames = @(
                'key.1'
                'key_1'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.KeyVault.KeyName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.KeyVault.KeyName';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }

    Context 'With Template' {
        BeforeAll {
            $templatePath = Join-Path -Path $here -ChildPath 'Resources.Template2.json';
            $parameterPath = Join-Path -Path $here -ChildPath 'Resources.Parameters2.json';
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.KeyVault.json;
            Export-AzRuleTemplateData -TemplateFile $templatePath -ParameterFile $parameterPath -OutputPath $outputFile;
            $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Outcome All -WarningAction Ignore -ErrorAction Stop;
        }

        It 'Azure.KeyVault.SoftDelete' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.SoftDelete' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'keyvault-001';
        }

        It 'Azure.KeyVault.PurgeProtect' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.PurgeProtect' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'keyvault-001';
        }

        It 'Azure.KeyVault.AccessPolicy' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.AccessPolicy' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'keyvault-001';
        }

        It 'Azure.KeyVault.Logs' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.Logs' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'keyvault-001';
        }

        It 'Azure.KeyVault.AutoRotationPolicy' {
            $result = Invoke-PSRule -Module PSRule.Rules.Azure -InputPath $outputFile -Baseline 'Azure.Preview' -Outcome All -WarningAction Ignore -ErrorAction Stop;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.AutoRotationPolicy' };

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'keyvault-001';

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'vault-002/key2', 'vault-002/key3';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The key (vault-002/key2) should enable a auto-rotation policy.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The key (vault-002/key3) should enable a auto-rotation policy.";

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult[0].TargetName | Should -BeLike '*Resources.Parameters2.json';
            $ruleResult[1].TargetName | Should -BeExactly 'kvstoragediag01';
        }

        It 'Azure.KeyVault.Firewall' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.KeyVault.Firewall' };

            # Fails
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'keyvault-001';
            
            # No passes
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -BeNullOrEmpty;
        }
    }
}
