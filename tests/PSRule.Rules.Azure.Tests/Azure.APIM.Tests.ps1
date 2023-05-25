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
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Outcome All;
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
            $ruleResult.Length | Should -Be 15;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C', 'apim-D', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P';
        }

        It 'Azure.APIM.Ciphers' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.Ciphers' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-A', 'apim-B';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 14;
            $ruleResult.TargetName | Should -BeIn 'apim-C', 'apim-D', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P';
        }

        It 'Azure.APIM.HTTPEndpoint' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.HTTPEndpoint' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'apim-A', 'apim-D';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 14;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P';
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
            $ruleResult.Length | Should -Be 14;
            $ruleResult.TargetName | Should -BeIn 'apim-A', 'apim-D', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P';
        }

        It 'Azure.APIM.HTTPBackend' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.HTTPBackend' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -Be 'apim-A', 'apim-D';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -HaveCount 2;
            $ruleResult[0].Reason | Should -Be @(
                "The backend URL for 'endpoint-B' is not a HTTPS endpoint.", 
                "The service URL for 'api-B' is not a HTTPS endpoint."
            );

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 14;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P';
        }

        It 'Azure.APIM.EncryptValues' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.EncryptValues' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'apim-A', 'apim-B', 'namedvalue-A', 'namedvalue-B';

            $ruleResult[0].Reason | Should -BeExactly "The named value 'namedvalue-A' is not a secret securely stored within a key vault.";
            $ruleResult[1].Reason | Should -BeExactly "The named value 'namedvalue-A' is not a secret securely stored within a key vault.", "The named value 'namedvalue-B' is not a secret securely stored within a key vault.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 15;
            $ruleResult.TargetName | Should -Be 'apim-C','apim-D', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P', 'namedvalue-C';
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
            $ruleResult.Length | Should -Be 14;
            $ruleResult.TargetName | Should -Be 'apim-A', 'apim-D', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P';
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
            $ruleResult.Length | Should -Be 15;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C', 'apim-D', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P';
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
            $ruleResult.Length | Should -Be 15;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C', 'apim-D', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P';
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
            $ruleResult.Length | Should -Be 15;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C', 'apim-D', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P';
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
            $ruleResult.Length | Should -Be 14;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-D', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P';
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
            $ruleResult.Length | Should -Be 15;
            $ruleResult.TargetName | Should -BeIn 'apim-A', 'apim-C', 'apim-D', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P';
        }

        It 'Azure.APIM.CertificateExpiry' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.CertificateExpiry' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 14;
            $ruleResult.TargetName | Should -Be 'apim-C', 'apim-D', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P';

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
            $ruleResult.Length | Should -Be 16;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-A', 'apim-C', 'apim-D', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P';
        }

        It 'Azure.APIM.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.AvailabilityZone' -and $_.TargetType -eq 'Microsoft.ApiManagement/service' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 8;
            $ruleResult.TargetName | Should -BeIn 'apim-D', 'apim-F', 'apim-G', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-P';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The API management service (apim-D) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -Be @(
                "The API management service (apim-F) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3]."
                "The API management service (apim-F) deployed to region (East US) should use a minimum of two availability zones from the following [1, 2, 3]."
            )
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -BeExactly "The API management service (apim-G) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -BeExactly "The API management service (apim-I) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "The API management service (apim-J) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -Be @(
                "The API management service (apim-K) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3]."
                "The API management service (apim-K) deployed to region (East US) should use a minimum of two availability zones from the following [1, 2, 3]."
            )
            $ruleResult[6].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[6].Reason | Should -BeExactly "The API management service (apim-L) deployed to region (Australia East) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[7].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[7].Reason | Should -BeExactly "The API management service (apim-P) deployed to region (East US) should use a minimum of two availability zones from the following [1, 2, 3].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 5;
            $ruleResult.TargetName | Should -BeIn 'apim-E', 'apim-H', 'apim-M', 'apim-N', 'apim-O';

            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'apim-A', 'apim-B', 'apim-C';
        }

        It 'Azure.APIM.MinAPIVersion' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.MinAPIVersion' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 13;
            $ruleResult.TargetName | Should -BeIn 'apim-A', 'apim-B', 'apim-C', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-L', 'apim-M', 'apim-N', 'apim-O', 'apim-P';

            $ruleResult[0].Reason | Should -BeExactly "The api management instance is missing minimum api version configuration.";
            $ruleResult[1].Reason | Should -BeExactly "The api management instance is missing minimum api version configuration.";
            $ruleResult[2].Reason | Should -BeExactly "The api management instance with minimum api version '2021-04-01-preview' is less than '2021-08-01'.";
            $ruleResult[3].Reason | Should -BeIn "The api management instance with api version '2021-04-01-preview' is less than '2021-08-01'.", "The api management instance with minimum api version '2021-04-01-preview' is less than '2021-08-01'.";
            
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'apim-D', 'apim-J', 'apim-K';
        }

        It 'Azure.APIM.MultiRegion' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.MultiRegion' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 6;
            $ruleResult.TargetName | Should -BeIn 'apim-D', 'apim-E', 'apim-H', 'apim-I', 'apim-J', 'apim-O';

            $ruleResult[0].Reason | Should -BeExactly "The API management instance should use multi-region deployment.";
            $ruleResult[1].Reason | Should -BeExactly "The API management instance should use multi-region deployment.";
            $ruleResult[2].Reason | Should -BeExactly "The API management instance should use multi-region deployment.";
            
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 7;
            $ruleResult.TargetName | Should -BeIn 'apim-F', 'apim-G', 'apim-K', 'apim-L', 'apim-M', 'apim-N', 'apim-P';
        }

        It 'Azure.APIM.MultiRegionGateway' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.MultiRegionGateway' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'apim-F', 'apim-G', 'apim-K';

            $ruleResult[0].Reason | Should -BeExactly "The field 'disableGateway' is set to 'True'.";
            $ruleResult[1].Reason | Should -BeExactly "The field 'disableGateway' is set to 'True'.";
            
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'apim-l', 'apim-M', 'apim-N', 'apim-P';
        }

        It 'Azure.APIM.CORSPolicy' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.CORSPolicy' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C', 'apim-D', 'policy-A';

            $ruleResult[0].Reason | Should -BeIn "Wildcard * for configuration options in CORS policies settings should not be configured.";
            $ruleResult[1].Reason | Should -BeIn "Wildcard * for configuration options in CORS policies settings should not be configured.";
            
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-E', 'policy-B';
        }

        It 'Azure.APIM.PolicyBase' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.PolicyBase' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 4;
            $ruleResult.TargetName | Should -BeIn 'apim-B', 'apim-C', 'api-policy-A', 'api-policy-B';

            $ruleResult[0].Reason | Should -BeIn "Path inbound.base: Does not exist.", "Path backend.base: Does not exist.", "Path outbound.base: Does not exist.", "Path on-error.base: Does not exist.";
            $ruleResult[1].Reason | Should -BeIn "Path inbound.base: Does not exist.", "Path backend.base: Does not exist.", "Path outbound.base: Does not exist.", "Path on-error.base: Does not exist.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-D', 'api-policy-C';
        }

        It 'Azure.APIM.DefenderCloud' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.DefenderCloud' };
            
            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'apim-A', 'apim-B', 'apim-C';

            $ruleResult[0].Reason | Should -BeIn "The API 'api-A' should be onboarded to Microsoft Defender for APIs.", "The API 'api-B' should be onboarded to Microsoft Defender for APIs.";
            $ruleResult[1].Reason | Should -BeIn "The API 'api-A' should be onboarded to Microsoft Defender for APIs."
            $ruleResult[2].Reason | Should -BeIn "The API 'api-A' should be onboarded to Microsoft Defender for APIs.";
            
            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'apim-D';
        }
    }

    Context 'With Template' {
        BeforeAll {
            $outputFile = Join-Path -Path $rootPath -ChildPath out/tests/Resources.APIM.json;
            Export-AzRuleTemplateData -TemplateFile (Join-Path -Path $here -ChildPath 'apim.tests.json') -OutputPath $outputFile;
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $result = Invoke-PSRule @invokeParams -InputPath $outputFile -Outcome All;
        }

        It 'Azure.APIM.HTTPBackend' {
            $filteredResult = $result | Where-Object {
                $_.RuleName -eq 'Azure.APIM.HTTPBackend' -and
                (
                    $_.TargetType -eq 'Microsoft.ApiManagement/service' -or
                    $_.TargetType -eq 'Microsoft.ApiManagement/service/apis' -or
                    $_.TargetType -eq 'Microsoft.ApiManagement/service/backends'
                )
            };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            # $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'apim-02/api-02';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            # $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'apim-01', 'apim-03/api-03';
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

    Context 'With Configuration Option' -Tag 'Configuration' {
        BeforeAll {
            $invokeParams = @{
                Baseline = 'Azure.All'
                Module = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction = 'Stop'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.APIM.json';
            $configPath = Join-Path -Path $here -ChildPath 'ps-rule-options.yaml';
        }

        It 'Azure.APIM.AvailabilityZone - HashTable option' {
            $option = @{
                'Configuration.AZURE_APIM_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST' = @(
                    [PSCustomObject]@{
                        Location = 'Antarctica North'
                        Zones = @("1", "2", "3")
                    }
                    [PSCustomObject]@{
                        Location = 'Antarctica South'
                        Zones = @("1", "2", "3")
                    }
                )
            }
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $option -Outcome All;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.AvailabilityZone' -and $_.TargetType -eq 'Microsoft.ApiManagement/service' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -BeIn 'apim-D', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-P';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The API management service (apim-D) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The API management service (apim-E) deployed to region (antarcticanorth) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -Be @(
                "The API management service (apim-F) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3]."
                "The API management service (apim-F) deployed to region (East US) should use a minimum of two availability zones from the following [1, 2, 3]."
            )
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -Be @(
                "The API management service (apim-G) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3]."
                "The API management service (apim-G) deployed to region (Antarctica South) should use a minimum of two availability zones from the following [1, 2, 3]."
            )
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "The API management service (apim-H) deployed to region (antarcticasouth) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The API management service (apim-I) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[6].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[6].Reason | Should -BeExactly "The API management service (apim-J) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[7].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[7].Reason | Should -Be @(
                "The API management service (apim-K) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3]."
                "The API management service (apim-K) deployed to region (East US) should use a minimum of two availability zones from the following [1, 2, 3]."
            )
            $ruleResult[8].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[8].Reason | Should -Be @(
                "The API management service (apim-L) deployed to region (antarcticanorth) should use a minimum of two availability zones from the following [1, 2, 3]."
                "The API management service (apim-L) deployed to region (Australia East) should use a minimum of two availability zones from the following [1, 2, 3]."
            )
            $ruleResult[9].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[9].Reason | Should -BeExactly "The API management service (apim-P) deployed to region (East US) should use a minimum of two availability zones from the following [1, 2, 3].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'apim-M', 'apim-N', 'apim-O';
            
            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'apim-A', 'apim-B', 'apim-C';
        }

        It 'Azure.APIM.AvailabilityZone - YAML file option' {
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option $configPath -Outcome All;
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.APIM.AvailabilityZone' -and $_.TargetType -eq 'Microsoft.ApiManagement/service' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 10;
            $ruleResult.TargetName | Should -BeIn 'apim-D', 'apim-E', 'apim-F', 'apim-G', 'apim-H', 'apim-I', 'apim-J', 'apim-K', 'apim-L', 'apim-P';

            $ruleResult[0].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[0].Reason | Should -BeExactly "The API management service (apim-D) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[1].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[1].Reason | Should -BeExactly "The API management service (apim-E) deployed to region (antarcticanorth) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[2].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[2].Reason | Should -Be @(
                "The API management service (apim-F) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3]."
                "The API management service (apim-F) deployed to region (East US) should use a minimum of two availability zones from the following [1, 2, 3]."
            )
            $ruleResult[3].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[3].Reason | Should -Be @(
                "The API management service (apim-G) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3]."
                "The API management service (apim-G) deployed to region (Antarctica South) should use a minimum of two availability zones from the following [1, 2, 3]."
            )
            $ruleResult[4].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[4].Reason | Should -BeExactly "The API management service (apim-H) deployed to region (antarcticasouth) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[5].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[5].Reason | Should -BeExactly "The API management service (apim-I) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[6].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[6].Reason | Should -BeExactly "The API management service (apim-J) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3].";
            $ruleResult[7].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[7].Reason | Should -Be @(
                "The API management service (apim-K) deployed to region (australiaeast) should use a minimum of two availability zones from the following [1, 2, 3]."
                "The API management service (apim-K) deployed to region (East US) should use a minimum of two availability zones from the following [1, 2, 3]."
            )
            $ruleResult[8].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[8].Reason | Should -Be @(
                "The API management service (apim-L) deployed to region (antarcticanorth) should use a minimum of two availability zones from the following [1, 2, 3]."
                "The API management service (apim-L) deployed to region (Australia East) should use a minimum of two availability zones from the following [1, 2, 3]."
            )
            $ruleResult[9].Reason | Should -Not -BeNullOrEmpty;
            $ruleResult[9].Reason | Should -BeExactly "The API management service (apim-P) deployed to region (East US) should use a minimum of two availability zones from the following [1, 2, 3].";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'apim-M', 'apim-N', 'apim-O';
            
            # None
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'None' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'apim-A', 'apim-B', 'apim-C';
        }
    }
}
