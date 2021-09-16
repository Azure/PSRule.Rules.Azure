# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for API Management
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

Describe 'Azure.APIM' -Tag 'APIM' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.APIM.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath;
        }

        It 'Azure.APIM.Protocols' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.Protocols' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'apim-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C';
        }

        It 'Azure.APIM.HTTPEndpoint' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.HTTPEndpoint' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'apim-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C';
        }

        It 'Azure.APIM.APIDescriptors' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.APIDescriptors' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C';
            $ruleResult[0].Reason | Should -BeLike "The API '*' does not have a description set.";

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The API 'api-B' does not have a description set.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The API 'api-B' does not have a description set.";


            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'apim-A';
        }

        It 'Azure.APIM.HTTPBackend' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.HTTPBackend' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'apim-A';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -HaveCount 2;
            $ruleResult[0].Reason | Should -Be @(
                "The backend URL for 'endpoint-B' is not a HTTPS endpoint.", 
                "The service URL for 'api-B' is not a HTTPS endpoint."
            );

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C';
        }

        It 'Azure.APIM.EncryptValues' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.EncryptValues' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-A', 'apim-C';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The named value 'property-B' is not secret.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The named value 'property-B' is not secret.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'apim-B';
        }

        It 'Azure.APIM.ProductSubscription' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.ProductSubscription' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The product 'product-B' does not require a subscription to use.";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The product 'product-B' does not require a subscription to use.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'apim-A';
        }

        It 'Azure.APIM.ProductApproval' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.ProductApproval' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'apim-A';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The product 'starter' does not require approval.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C';
        }

        It 'Azure.APIM.SampleProducts' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.SampleProducts' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'apim-A';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C';
        }

        It 'Azure.APIM.ProductDescriptors' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.ProductDescriptors' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'apim-A';
            $ruleResult[0].Reason | Should -BeLike "The product 'product-*' does not have a description set.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C';
        }

        It 'Azure.APIM.ProductTerms' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.ProductTerms' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-A', 'apim-C';
            
            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -HaveCount 4;
            $ruleResult[0].Reason | Should -Be @(
                "The product 'product-A' does not have legal terms set.", 
                "The product 'product-B' does not have legal terms set.", 
                "The product 'starter' does not have legal terms set.", 
                "The product 'unlimited' does not have legal terms set."
            );

            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -HaveCount 2;
            $ruleResult[1].Reason | Should -Be @(
                "The product 'product-A' does not have legal terms set.",
                "The product 'product-B' does not have legal terms set."
            );

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'apim-B';
        }

        It 'Azure.APIM.ManagedIdentity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.ManagedIdentity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'apim-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-A', 'apim-C';
        }

        It 'Azure.APIM.CertificateExpiry' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.CertificateExpiry' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'apim-C';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The certificate for host name 'api.contoso.com' expires or expired on '2020/01/01'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-A';
        }

        It 'Azure.APIM.Name' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.Name' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -BeNullOrEmpty;

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-A', 'apim-C';
        }
    }

    Context 'Resource name' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $testObject = [PSCustomObject]@{
                Name = ''
                ResourceType = 'Microsoft.ApiManagement/service'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'apim-1'
                'APIM001'
                'a'
            )
            $invalidNames = @(
                '_apim1'
                '-apim1'
                'apim1_'
                'apim1-'
                '1apim'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.APIM.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.APIM.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Fail';
        }
    }
}
