# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for API Management
#

# Synopsis: Enforce HTTPS for communication to API clients.
Rule 'Azure.APIM.HTTPEndpoint' -Ref 'AZR-000042' -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/apis' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-3' } {
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $apis = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/apis')
        if ($apis.Length -eq 0) {
            return $Assert.Pass();
        }
        foreach ($api in $apis) {
            $Assert.NotIn($api, 'properties.protocols', @('http'))
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service/apis') {
        $Assert.NotIn($TargetObject, 'properties.protocols', @('http'))
    }
}

# Synopsis: APIs should have descriptors set
Rule 'Azure.APIM.APIDescriptors' -Ref 'AZR-000043' -Level Warning -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/apis' -Tag @{ release = 'GA'; ruleSet = '2020_09'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $apis = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $apis = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/apis');
    }
    if ($apis.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($api in $apis) {
        $Assert.
        HasFieldValue($api, 'Properties.displayName').
        Reason($LocalizedData.APIMDescriptors, 'API', $api.name, 'displayName');
        $Assert.
        HasFieldValue($api, 'Properties.description').
        Reason($LocalizedData.APIMDescriptors, 'API', $api.name, 'description');
    }
}

# Synopsis: Use HTTPS for communication to backend services.
Rule 'Azure.APIM.HTTPBackend' -Ref 'AZR-000044' -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/backends', 'Microsoft.ApiManagement/service/apis' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-3' } {
    $apis = @();
    $backends = @();

    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $backends = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/backends' | Where-Object {
                $Assert.HasField($_, 'properties.url').Result
            });
        $apis = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/apis' | Where-Object {
                $Assert.HasField($_, 'properties.serviceUrl').Result
            });
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service/apis') {
        if ($Assert.HasField($TargetObject, 'properties.serviceUrl').Result) {
            $apis = @($TargetObject)
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service/backends') {
        if ($Assert.HasField($TargetObject, 'properties.url').Result) {
            $backends = @($TargetObject)
        }
    }

    if ($backends.Length -eq 0 -and $apis.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($backend in $backends) {
        $Assert.
        NotStartsWith($backend, 'properties.url', 'http://').
        Reason($LocalizedData.BackendUrlNotHttps, $backend.name);
    }
    foreach ($api in $apis) {
        $Assert.
        NotStartsWith($api, 'properties.serviceUrl', 'http://').
        Reason($LocalizedData.ServiceUrlNotHttps, $api.name);
    }
}

# Synopsis: Encrypt all named values
Rule 'Azure.APIM.EncryptValues' -Ref 'AZR-000045' -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/properties', 'Microsoft.ApiManagement/service/namedValues' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = @('IM-8', 'DP-7') } {
    $properties = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $properties = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/properties', 'Microsoft.ApiManagement/service/namedValues');
    }
    if ($properties.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($property in $properties) {
        $Assert.
        HasFieldValue($property, 'properties.secret', $True).
        WithReason(($LocalizedData.APIMSecretNamedValues -f $property.name), $True);
    }
}

# Synopsis: Require subscription for products
Rule 'Azure.APIM.ProductSubscription' -Ref 'AZR-000046' -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/products' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $products = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $products = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/products');
    }
    if ($products.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($product in $products) {
        $Assert.
        HasFieldValue($product, 'Properties.subscriptionRequired', $True).
        WithReason(($LocalizedData.APIMProductSubscription -f $product.Name), $True);
    }
}

# Synopsis: Require approval for products
Rule 'Azure.APIM.ProductApproval' -Ref 'AZR-000047' -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/products' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } {
    $products = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $products = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/products');
    }
    if ($products.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($product in $products) {
        $Assert.
        HasFieldValue($product, 'Properties.approvalRequired', $True).
        WithReason(($LocalizedData.APIMProductApproval -f $product.Name), $True);
    }
}

# Synopsis: Remove sample products
Rule 'Azure.APIM.SampleProducts' -Ref 'AZR-000048' -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/products' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $products = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $products = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/products');
    }
    if ($products.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($product in $products) {
        $Assert.NotIn($product, 'Name', @('unlimited', 'starter'))
    }
}

# Synopsis: Products should have descriptors set
Rule 'Azure.APIM.ProductDescriptors' -Ref 'AZR-000049' -Level Warning -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/products' -Tag @{ release = 'GA'; ruleSet = '2020_09'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $products = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $products = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/products');
    }
    if ($products.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($product in $products) {
        $Assert.
        HasFieldValue($product, 'Properties.displayName').
        WithReason(($LocalizedData.APIMDescriptors -f 'product', $product.name, 'displayName'), $True);
        $Assert.
        HasFieldValue($product, 'Properties.description').
        WithReason(($LocalizedData.APIMDescriptors -f 'product', $product.name, 'description'), $True);
    }
}

# Synopsis: Use product terms
Rule 'Azure.APIM.ProductTerms' -Ref 'AZR-000050' -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/products' -Tag @{ release = 'GA'; ruleSet = '2020_09'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    $products = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $products = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/products');
    }
    if ($products.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($product in $products) {
        $Assert.
        HasFieldValue($product, 'Properties.terms').
        WithReason(($LocalizedData.APIMProductTerms -f $product.name), $True);
    }
}

# Synopsis: Renew expired certificates
Rule 'Azure.APIM.CertificateExpiry' -Ref 'AZR-000051' -Type 'Microsoft.ApiManagement/service' -Tag @{ release = 'GA'; ruleSet = '2020_06'; 'Azure.WAF/pillar' = 'Security'; } -Labels @{ 'Azure.MCSB.v1/control' = 'DP-7' } {
    $configurations = @($TargetObject.Properties.hostnameConfigurations | Where-Object {
            $Null -ne $_.certificate
        })
    if ($configurations.Length -eq 0) {
        return $Assert.Pass();
    }
    foreach ($configuration in $configurations) {
        $remaining = ($configuration.certificate.expiry - [DateTime]::Now).Days;
        $Assert.
        GreaterOrEqual($remaining, '.', $Configuration.Azure_MinimumCertificateLifetime).
        WithReason(($LocalizedData.APIMCertificateExpiry -f $configuration.hostName, $configuration.certificate.expiry.ToString('yyyy/MM/dd')), $True);
    }
} -Configure @{ Azure_MinimumCertificateLifetime = 30 }

# Synopsis: API management services deployed with Premium SKU should use availability zones in supported regions for high availability.
Rule 'Azure.APIM.AvailabilityZone' -Ref 'AZR-000052' -Type 'Microsoft.ApiManagement/service' -If { IsPremiumAPIM } -Tag @{ release = 'GA'; ruleSet = '2021_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $apiManagementServiceProvider = [PSRule.Rules.Azure.Runtime.Helper]::GetResourceType('Microsoft.ApiManagement', 'service');

    $configurationZoneMappings = $Configuration.AZURE_APIM_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST;
    $providerZoneMappings = $apiManagementServiceProvider.ZoneMappings;
    $mergedAvailabilityZones = PrependConfigurationZoneWithProviderZone -ConfigurationZone $configurationZoneMappings -ProviderZone $providerZoneMappings;

    $primaryLocationAvailabilityZones = GetAvailabilityZone -Location $TargetObject.Location -Zone $mergedAvailabilityZones;

    # Validate primary location availability zones
    if (-not $primaryLocationAvailabilityZones) {
        $Assert.Pass();
    }
    else {
        $hasValidUnits = $Assert.GreaterOrEqual($TargetObject, 'sku.capacity', $TargetObject.zones.Length).Result;
        $hasValidZones = $Assert.GreaterOrEqual($TargetObject, 'zones', 2).Result;

        $Assert.Create(
            ($hasValidUnits -and $hasValidZones),
            $LocalizedData.APIMAvailabilityZone, 
            $TargetObject.name, 
            $TargetObject.Location, 
            ($primaryLocationAvailabilityZones -join ', ')
        )
    }

    # Also validate any additional locations that are added to APIM
    if (-not $Assert.NullOrEmpty($TargetObject, 'Properties.additionalLocations').Result) {

        foreach ($additionalLocation in $TargetObject.Properties.additionalLocations) {
            $additionalLocationAvailabilityZones = GetAvailabilityZone -Location $additionalLocation.Location -Zone $mergedAvailabilityZones;

            if (-not $additionalLocationAvailabilityZones) {
                $Assert.Pass();
            }
            else {
                $hasValidUnits = $Assert.GreaterOrEqual($additionalLocation, 'sku.capacity', $additionalLocation.zones.Length).Result;
                $hasValidZones = $Assert.GreaterOrEqual($additionalLocation, 'zones', 2).Result;

                $Assert.Create(
                    ($hasValidUnits -and $hasValidZones),
                    $LocalizedData.APIMAvailabilityZone, 
                    $TargetObject.name, 
                    $additionalLocation.Location, 
                    ($additionalLocationAvailabilityZones -join ', ')
                );
            }
        }
    }
} -Configure @{ AZURE_APIM_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST = @() }

# Synopsis: API Management instances should limit control plane API calls to API Management with version '2021-08-01' or newer.
Rule 'Azure.APIM.MinAPIVersion' -Ref 'AZR-000321' -Type 'Microsoft.ApiManagement/service' -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Operational Excellence'; } {
    if ($TargetObject.apiVersion) {
        [datetime]$versionConfigured = $TargetObject.apiVersion -replace '-preview', ''
        [datetime]$minimumVersionExpected = $Configuration.AZURE_APIM_MIN_API_VERSION -replace '-preview', ''

        $Assert.Create($versionConfigured -ge $minimumVersionExpected, $LocalizedData.APIMApiVersionMin, $TargetObject.apiVersion,
        $Configuration.AZURE_APIM_MIN_API_VERSION).PathPrefix('apiVersion')
    }
    if ($TargetObject.properties.apiVersionConstraint.minApiVersion) {
        [datetime]$minApiVersionConfigured = $TargetObject.properties.apiVersionConstraint.minApiVersion -replace '-preview', ''
        [datetime]$minApiVersionExpected = $Configuration.AZURE_APIM_MIN_API_VERSION -replace '-preview', ''

        $Assert.Create($minApiVersionConfigured -ge $minApiVersionExpected, $LocalizedData.APIMApiVersionConstraintMinApiVersion,
        $TargetObject.properties.apiVersionConstraint.minApiVersion, $Configuration.AZURE_APIM_MIN_API_VERSION).
        PathPrefix('properties.apiVersionConstraint.minApiVersion')
    }
    else {
        $Assert.Fail().Reason($LocalizedData.APIMApiVersionConstraintMinApiVersionNotFound)
    }
} -Configure @{ AZURE_APIM_MIN_API_VERSION = '2021-08-01' }

# Synopsis: API Management instances should use multi-region deployment to improve service availability.
Rule 'Azure.APIM.MultiRegion' -Ref 'AZR-000340' -Type 'Microsoft.ApiManagement/service' -If { IsPremiumAPIM } -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $Assert.GreaterOrEqual($TargetObject, 'properties.additionalLocations', 1).Reason($LocalizedData.APIMMultiRegion)
}

# Synopsis: API Management instances should have multi-region deployment gateways enabled.
Rule 'Azure.APIM.MultiRegionGateway' -Ref 'AZR-000341' -Type 'Microsoft.ApiManagement/service' -If { (IsPremiumAPIM) -and (IsMultiRegion) } -Tag @{ release = 'GA'; ruleSet = '2022_12'; 'Azure.WAF/pillar' = 'Reliability'; } {
    $gateways = $PSRule.GetPath($TargetObject, 'properties.additionalLocations')
    foreach ($gateway in $gateways) {
        $Assert.HasDefaultValue($gateway, 'disableGateway', $False)
    }
}

#region Helper functions

function global:IsPremiumAPIM {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        return $Assert.HasFieldValue($TargetObject, 'sku.name', 'Premium').Result;
    }
}

function global:IsMultiRegion {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()
    process {
        $Assert.GreaterOrEqual($TargetObject, 'properties.additionalLocations', 1).Result
    }
}

#endregion Helper functions
