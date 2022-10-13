# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for Azure deployments
#

#region Rules

# Synopsis: Avoid outputting sensitive deployment values.
Rule 'Azure.Deployment.OutputSecretValue' -Ref 'AZR-000279' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2022_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $Assert.Create($PSRule.Issue.Get('PSRule.Rules.Azure.Template.OutputSecretValue'));
}

# Synopsis: Ensure all properties named used for setting a username within a deployment are expressions (e.g. an ARM function not a string)
Rule 'Azure.Deployment.AdminUsername' -Ref 'AZR-000284' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2022_09'; 'Azure.WAF/pillar' = 'Security'; } {
    RecurseDeploymentSensitive -Deployment $TargetObject
}

# Synopsis: Use secure parameters for setting properties of resources that contain sensitive information.
Rule 'Azure.Deployment.SecureValue' -Ref 'AZR-000314' -Type 'Microsoft.Resources/deployments' -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Security'; } {
    RecurseSecureValue -Deployment $TargetObject
}

#endregion Rules

#region Helpers

function global:RecurseDeploymentSensitive {
    param (
        [Parameter(Mandatory = $True)]
        [PSObject]$Deployment
    )
    process {
        $propertyNames = $Configuration.GetStringValues('AZURE_DEPLOYMENT_SENSITIVE_PROPERTY_NAMES');
        $resources = @($Deployment.properties.template.resources);
        if ($resources.Length -eq 0) {
            return $Assert.Pass();
        }

        foreach ($resource in $resources) {
            if ($resource.type -eq 'Microsoft.Resources/deployments') {
                RecurseDeploymentSensitive -Deployment $resource;
            }
            else {
                foreach ($propertyName in $propertyNames) {
                    $found = $PSRule.GetPath($resource, "$..$propertyName");
                    if ($Null -eq $found -or $found.Length -eq 0) {
                        $Assert.Pass();
                    }
                    else {
                        Write-Debug "Found property name: $propertyName";
                        foreach ($value in $found) {
                            $Assert.Create(![PSRule.Rules.Azure.Runtime.Helper]::HasLiteralValue($value), $LocalizedData.LiteralSensitiveProperty, $propertyName);
                        }
                    }
                }
            }
        }
    }
}

function global:CheckPropertyUsesSecureParameter {
    param (
        [Parameter(Mandatory = $True)]
        [PSObject]$Resource,

        [Parameter(Mandatory = $True)]
        [AllowEmptyCollection()]
        [PSObject]$SecureParameters,

        [Parameter(Mandatory = $True)]
        [String]$PropertyPath
    )
    process {
        $propertiesInPath = $PropertyPath.Split(".")
        $propertyValue = $Resource
        # TODO add test for when the whole property path is not present in the template
        foreach($aPropertyInThePath in $propertiesInPath) {
            $propertyValue = $propertyValue."$aPropertyInThePath"
        }

        if ($propertyValue) {
            $isSecure = [PSRule.Rules.Azure.Runtime.Helper]::HasValueFromSecureParameter($propertyValue, $SecureParameters);
            $Assert.Create($isSecure).Reason($LocalizedData.SecureParameterRequired, $PropertyPath);
        }
        else {
            $Assert.Pass();
        }
    }
}

# Check resource properties that should be set by secure parameters.
function global:RecurseSecureValue {
    param (
        [Parameter(Mandatory = $True)]
        [PSObject]$Deployment
    )
    process {
        $resources = @($Deployment.properties.template.resources);
        if ($resources.Length -eq 0) {
            return $Assert.Pass();
        }

        $secureParameters = @($Deployment.properties.template.parameters.PSObject.properties | Where-Object {
            $_.Value.type -eq 'secureString' -or $_.Value.type -eq 'secureObject'
        } | ForEach-Object {
            $_.Name
        });
        Write-Debug -Message "Secure parameters are: $($secureParameters -join ', ')";

        foreach ($resource in $resources) {
            switch ($resource.type)
            {
                'Microsoft.Resources/Deployments' { 
                    RecurseSecureValue -Deployment $resource;
                }
                'Microsoft.AAD/DomainServices' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath 'properties.ldapsSettings.pfxCertificatePassword'
                }
                'Microsoft.ApiManagement/Service' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath 'properties.hostnameConfigurations.certificatePassword'
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath 'properties.certificates.certificatePassword'
                }
                'Microsoft.ApiManagement/Service/AuthorizationServers' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath 'properties.clientSecret'
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath 'properties.resourceOwnerPassword'
                }
                'Microsoft.ApiManagement/Service/Backends' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.proxy.password"
                }
                'Microsoft.ApiManagement/Service/Certificates' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.password"
                }
                'Microsoft.ApiManagement/Service/IdentityProviders' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.clientSecret"
                }
                'Microsoft.ApiManagement/Service/OpenidConnectProviders' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.clientSecret"
                }
                'Microsoft.ApiManagement/Service/Users' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.password"
                }
                'Microsoft.Automation/AutomationAccounts/Credentials' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.password"
                }
                'Microsoft.Batch/BatchAccounts/Pools' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.userAccounts.linuxUserConfiguration.sshPrivateKey"
                }
                'Microsoft.Blockchain/BlockchainMembers' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.password"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.consortiumManagementAccountPassword"
                }
                'Microsoft.Blockchain/BlockchainMembers/TransactionNodes' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.password"
                }
                'Microsoft.BotService/BotServices/Connections' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.clientSecret"
                }
                'Microsoft.Compute/VirtualMachineScaleSets' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath 'properties.virtualMachineProfile.osProfile.adminPassword'
                }
                'Microsoft.Compute/VirtualMachineScaleSets/Virtualmachines' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.osProfile.adminPassword"
                }
                'Microsoft.Compute/VirtualMachines' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath 'properties.osProfile.adminPassword'
                }
                'Microsoft.ContainerInstance/ContainerGroups' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.imageRegistryCredentials.password"
                }
                'Microsoft.ContainerService/ContainerServices' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.servicePrincipalProfile.secret"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.windowsProfile.adminPassword"
                }
                'Microsoft.ContainerService/ManagedClusters' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath 'properties.windowsProfile.adminPassword'
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath 'properties.servicePrincipalProfile.secret'
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath 'properties.aadProfile.serverAppSecret'
                }
                'Microsoft.ContainerService/OpenShiftManagedClusters' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath 'properties.authProfile.identityProviders.provider.secret'
                }
                'Microsoft.DBforMariaDB/Servers' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.administratorLoginPassword"
                }
                'Microsoft.DBforMySQL/Servers' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.administratorLoginPassword"
                }
                'Microsoft.DBforPostgreSQL/Servers' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.administratorLoginPassword"
                }
                'Microsoft.DataMigration/Services/Projects' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.sourceConnectionInfo.password"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.targetConnectionInfo.password"
                }
                'Microsoft.DevTestLab/Labs/Formulas' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.formulaContent.properties.password"
                }
                'Microsoft.DevTestLab/Labs/Users/Secrets' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.value"
                }
                'Microsoft.DevTestLab/Labs/Virtualmachines' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.password"
                }
                'Microsoft.HDInsight/Clusters' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.securityProfile.domainUserPassword"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.computeProfile.roles.osProfile.linuxOperatingSystemProfile.password"
                }
                'Microsoft.HDInsight/Clusters/Applications' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.computeProfile.roles.osProfile.linuxOperatingSystemProfile.password"
                }
                'Microsoft.KeyVault/Vaults/Secrets' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath 'properties.value'
                }
                'Microsoft.Logic/IntegrationAccounts/Agreements' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.content.x12.receiveAgreement.protocolSettings.securitySettings.passwordValue"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.content.x12.sendAgreement.protocolSettings.securitySettings.passwordValue"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.content.edifact.receiveAgreement.protocolSettings.envelopeSettings.recipientReferencePasswordValue"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.content.edifact.sendAgreement.protocolSettings.envelopeSettings.recipientReferencePasswordValue"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.content.edifact.receiveAgreement.protocolSettings.envelopeSettings.groupApplicationPassword"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.content.edifact.sendAgreement.protocolSettings.envelopeSettings.groupApplicationPassword"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.content.edifact.receiveAgreement.protocolSettings.envelopeOverrides.applicationPassword"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.content.edifact.sendAgreement.protocolSettings.envelopeOverrides.applicationPassword"
                }
                'Microsoft.NetApp/NetAppAccounts' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.activeDirectories.password"
                }
                'Microsoft.Network/ApplicationGateways' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.sslCertificates.properties.password"
                }
                'Microsoft.Network/Connections' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.virtualNetworkGateway1.properties.vpnClientConfiguration.radiusServerSecret"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.virtualNetworkGateway2.properties.vpnClientConfiguration.radiusServerSecret"
                }
                'Microsoft.Network/VirtualNetworkGateways' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.vpnClientConfiguration.radiusServerSecret"
                }
                'Microsoft.Network/VirtualWans/P2sVpnServerConfigurations' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.radiusServerSecret"
                }
                'Microsoft.Network/VpnServerConfigurations' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.radiusServerSecret"
                }
                'Microsoft.NotificationHubs/Namespaces/NotificationHubs' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.wnsCredential.properties.secretKey"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.admCredential.properties.clientSecret"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.baiduCredential.properties.baiduSecretKey"
                }
                'Microsoft.ServiceFabricMesh/Applications' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.services.properties.codePackages.imageRegistryCredential.password"
                }
                'Microsoft.ServiceFabricMesh/Secrets/Values' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.value"
                }
                'Microsoft.Sql/ManagedInstances' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.administratorLoginPassword"
                }
                'Microsoft.Sql/Servers' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.administratorLoginPassword"
                }
                'Microsoft.Sql/Servers/Databases/Extensions' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.administratorLoginPassword"
                }
                'Microsoft.Sql/Servers/Databases/SyncGroups' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.hubDatabasePassword"
                }
                'Microsoft.Sql/Servers/Databases/SyncGroups/SyncMembers' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.password"
                }
                'Microsoft.Sql/Servers/JobAgents/Credentials' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.password"
                }
                'Microsoft.SqlVirtualMachine/SqlVirtualMachines' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.wsfcDomainCredentials.clusterBootstrapAccountPassword"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.wsfcDomainCredentials.clusterOperatorAccountPassword"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.wsfcDomainCredentials.sqlServiceAccountPassword"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.autoBackupSettings.password"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.keyVaultCredentialSettings.servicePrincipalSecret"
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.serverConfigurationsManagementSettings.sqlConnectivityUpdateSettings.sqlAuthUpdatePassword"
                }
                'Microsoft.StorSimple/Managers/Devices/VolumeContainers' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.encryptionKey.value"
                }
                'Microsoft.StorSimple/Managers/StorageAccountCredentials' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.accessKey.value"
                }
                'Microsoft.StreamAnalytics/Streamingjobs' {
                    $passwords = ($resource.properties.inputs + $resource.properties.outputs) | Where-Object { $null -ne $_.properties.datasource.properties.password } # TODO check for null or another way to check is defined?

                    foreach ($password in $passwords) {
                        CheckPropertyUsesSecureParameter -Resource $password -SecureParameters $secureParameters -PropertyPath "properties.datasource.properties.password"
                    }
                }
                'Microsoft.StreamAnalytics/Streamingjobs/Outputs' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.datasource.properties.password"
                }
                'Microsoft.Web/Certificates' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.password"
                }
                'Microsoft.Web/Sourcecontrols' {
                    CheckPropertyUsesSecureParameter -Resource $resource -SecureParameters $secureParameters -PropertyPath "properties.tokenSecret"
                }
                Default {
                    $Assert.Pass();
                }
            }
        }
    }
}

#endregion Helpers