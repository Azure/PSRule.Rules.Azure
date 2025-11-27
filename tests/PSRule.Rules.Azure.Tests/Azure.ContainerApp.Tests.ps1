# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for Container Apps
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

Describe 'Azure.ContainerApp' -Tag 'ContainerApp' {
    Context 'Conditions' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
                Outcome       = 'All'
            }
            $dataPath = Join-Path -Path $here -ChildPath 'Resources.ContainerApp.json';
            $result = Invoke-PSRule @invokeParams -InputPath $dataPath -Option @{
                'Configuration.AZURE_CONTAINERAPPS_RESTRICT_INGRESS' = $True
            }
        }

        It 'Azure.ContainerApp.Insecure' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.Insecure' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-B', 'capp-D';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-A', 'capp-C';
        }

        It 'Azure.ContainerApp.ManagedIdentity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.ManagedIdentity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-A', 'capp-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'identity.type'

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-C', 'capp-D';
        }

        It 'Azure.ContainerApp.PublicAccess' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.PublicAccess' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-env-A', 'capp-env-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.vnetConfiguration.internal'

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'capp-env-C';
        }

        It 'Azure.ContainerApp.ExternalIngress' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.ExternalIngress' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-B', 'capp-C';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.configuration.ingress.external'

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-A', 'capp-D';
        }

        It 'Azure.ContainerApp.Storage' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.Storage' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'capp-C';
            # Todo: $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.template.volumes.storageType'

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'capp-D';
        }

        It 'Azure.ContainerApp.DisableAffinity' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.DisableAffinity' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'capp-A';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.configuration.ingress.stickySessions.affinity'

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'capp-B', 'capp-C', 'capp-D';
        }

        It 'Azure.ContainerApp.RestrictIngress' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.RestrictIngress' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 3;
            $ruleResult.TargetName | Should -BeIn 'capp-A', 'capp-B', 'capp-C';

            $ruleResult[0].Reason | Should -BeLike $null;
            $ruleResult[1].Reason | Should -BeLike "Path action: Is set to 'Deny'.";

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'capp-D';
        }

        It 'Azure.ContainerApp.APIVersion' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.APIVersion' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-A', 'capp-B';

            $ruleResult.Detail.Reason.Path | Should -BeIn 'apiVersion';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-C', 'capp-D';
        }

        It 'Azure.ContainerApp.MinReplicas' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.MinReplicas' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-A', 'capp-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.template.scale.minReplicas';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-C', 'capp-D';
        }

        It 'Azure.ContainerApp.AvailabilityZone' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.AvailabilityZone' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'capp-env-A', 'capp-env-B';
            $ruleResult.Detail.Reason.Path | Should -BeIn 'properties.zoneRedundant', 'properties.vnetConfiguration.infrastructureSubnetId';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -BeIn 'capp-env-C';
        }
    }

    Context 'Resource name - Azure.ContainerApp.Name' {
        BeforeAll {
            $invokeParams = @{
                Baseline      = 'Azure.All'
                Module        = 'PSRule.Rules.Azure'
                WarningAction = 'Ignore'
                ErrorAction   = 'Stop'
            }

            $testObject = [PSCustomObject]@{
                Name         = ''
                ResourceType = 'Microsoft.App/containerApps'
            }
        }

        BeforeDiscovery {
            $validNames = @(
                'capp-01'
                'a1'
                'capplication-01'
            )

            $invalidNames = @(
                'a'
                'capp-.'
                'capp-a-'
                'CAPP-A'
                'capp-01!'
                'capp.-01'
                'caaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaapplication-01'
            )
        }

        # Pass
        It '<_>' -ForEach $validNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.ContainerApp.Name';
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Outcome | Should -Be 'Pass';
        }

        # Fail
        It '<_>' -ForEach $invalidNames {
            $testObject.Name = $_;
            $ruleResult = $testObject | Invoke-PSRule @invokeParams -Name 'Azure.ContainerApp.Name';
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
                'AZURE_CONTAINER_APP_NAME_FORMAT'             = '^ca-'
                'AZURE_CONTAINER_APP_ENVIRONMENT_NAME_FORMAT' = '^cae-'
                'AZURE_CONTAINER_APP_JOB_NAME_FORMAT'         = '^caj-'
            };

            $appNames = @(
                'app-001'
                'ca-001'
                'CA-001'
            )

            $envNames = @(
                'env-001'
                'cae-001'
                'CAE-001'
            )

            $jobNames = @(
                'job-001'
                'caj-001'
                'CAJ-001'
            )

            $appItems = @($appNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.App/containerApps'
                    }
                });

            $envItems = @($envNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.App/managedEnvironments'
                    }
                });

            $jobItems = @($jobNames | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_
                        Type = 'Microsoft.App/jobs'
                    }
                });

            $result = @($appItems + $envItems + $jobItems) | Invoke-PSRule @invokeParams -Option $option -Name @(
                'Azure.ContainerApp.Naming'
                'Azure.ContainerApp.EnvNaming'
                'Azure.ContainerApp.JobNaming'
            )
        }

        It 'Azure.ContainerApp.Naming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.Naming' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'app-001', 'CA-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'ca-001';
        }

        It 'Azure.ContainerApp.EnvNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.EnvNaming' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'env-001', 'CAE-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'cae-001';
        }

        It 'Azure.ContainerApp.JobNaming' {
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'Azure.ContainerApp.JobNaming' };

            # Fail
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Fail' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 2;
            $ruleResult.TargetName | Should -BeIn 'job-001', 'CAJ-001';

            # Pass
            $ruleResult = @($filteredResult | Where-Object { $_.Outcome -eq 'Pass' });
            $ruleResult | Should -Not -BeNullOrEmpty;
            $ruleResult.Length | Should -Be 1;
            $ruleResult.TargetName | Should -Be 'caj-001';
        }
    }
}
