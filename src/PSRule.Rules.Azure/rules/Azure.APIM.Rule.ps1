# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Validation rules for API Management
#

# Synopsis: Disable insecure protocols and ciphers
Rule 'Azure.APIM.Protocols' -Type 'Microsoft.ApiManagement/service' -Tag @{ release = 'GA' } {
    $Assert.HasDefaultValue($TargetObject, 'properties.customProperties.''Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10''', 'False')
    $Assert.HasDefaultValue($TargetObject, 'properties.customProperties.''Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11''', 'False')
    $Assert.HasDefaultValue($TargetObject, 'properties.customProperties.''Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30''', 'False')
    $Assert.HasDefaultValue($TargetObject, 'properties.customProperties.''Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168''', 'False')
    $Assert.HasDefaultValue($TargetObject, 'properties.customProperties.''Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10''', 'False')
    $Assert.HasDefaultValue($TargetObject, 'properties.customProperties.''Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11''', 'False')
    $Assert.HasDefaultValue($TargetObject, 'properties.customProperties.''Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30''', 'False')
}

# Synopsis: Use HTTPS apis
Rule 'Azure.APIM.HTTPEndpoint' -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/apis' -Tag @{ release = 'GA' } {
    Reason 'http is in use'
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $apis = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/apis')
        if ($apis.Length -eq 0) {
            $True;
        }
        foreach ($api in $apis) {
            'http' -notin @($api.properties.protocols)
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service/apis') {
        'http' -notin @($TargetObject.properties.protocols)
    }
}

# Synopsis: Use HTTPS backends
Rule 'Azure.APIM.HTTPBackend' -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/backends', 'Microsoft.ApiManagement/service/apis' -Tag @{ release = 'GA' } {
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $backends = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/backends')
        if ($backends.Length -eq 0) {
            $True;
        }
        foreach ($backend in $backends) {
            $Assert.
                StartsWith($backend, 'properties.url', 'https://').
                WithReason(($LocalizedData.BackendUrlNotHttps -f $backend.name), $True);
        }
        $apis = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/apis')
        if ($apis.Length -eq 0) {
            $True;
        }
        foreach ($api in $apis) {
            $Assert.
                StartsWith($api, 'properties.serviceUrl', 'https://').
                WithReason(($LocalizedData.ServiceUrlNotHttps -f $api.name), $True);
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service/apis') {
        $Assert.
            StartsWith($TargetObject, 'properties.serviceUrl', 'https://').
            WithReason(($LocalizedData.ServiceUrlNotHttps -f $PSRule.TargetName), $True);
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service/backends') {
        $Assert.
            StartsWith($TargetObject, 'properties.url', 'https://').
            WithReason(($LocalizedData.BackendUrlNotHttps -f $PSRule.TargetName), $True);
    }
}

# Synopsis: Encrypt all named values
Rule 'Azure.APIM.EncryptValues' -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/properties', 'Microsoft.ApiManagement/service/namedValues' -Tag @{ release = 'GA' } {
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $properties = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/properties', 'Microsoft.ApiManagement/service/namedValues')
        if ($properties.Length -eq 0) {
            $True;
        }
        foreach ($prop in $properties) {
            $Assert.HasFieldValue($prop, 'properties.secret', $True)
        }
    }
    elseif ($PSRule.TargetType -in 'Microsoft.ApiManagement/service/properties', 'Microsoft.ApiManagement/service/namedValues') {
        $Assert.HasFieldValue($TargetObject, 'properties.secret', $True)
    }
}

# Synopsis: Require subscription for products
Rule 'Azure.APIM.ProductSubscription' -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/products' -Tag @{ release = 'GA' } {
    $products = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $products = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/products');
        if ($products.Length -eq 0) {
            $True;
        }
    }
    foreach ($product in $products) {
        $Assert.
            HasFieldValue($product, 'Properties.subscriptionRequired', $True).
            WithReason(($LocalizedData.APIMProductSubscription -f $product.Name), $True);
    }
}

# Synopsis: Require approval for products
Rule 'Azure.APIM.ProductApproval' -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/products' -Tag @{ release = 'GA' } {
    $products = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $products = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/products');
        if ($products.Length -eq 0) {
            $True;
        }
    }
    foreach ($product in $products) {
        $Assert.
            HasFieldValue($product, 'Properties.approvalRequired', $True).
            WithReason(($LocalizedData.APIMProductApproval -f $product.Name), $True);
    }
}

# Synopsis: Remove sample products
Rule 'Azure.APIM.SampleProducts' -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/products' -Tag @{ release = 'GA' } {
    $products = @($TargetObject);
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $products = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/products');
        if ($products.Length -eq 0) {
            $True;
        }
    }
    foreach ($product in $products) {
        $product | Within 'Name' -Not 'unlimited', 'starter'
    }
}

# Synopsis: Provision a managed identity
Rule 'Azure.APIM.ManagedIdentity' -Type 'Microsoft.ApiManagement/service' -Tag @{ release = 'GA' } {
    Within 'Identity.Type' 'SystemAssigned', 'UserAssigned'
}

# Synopsis: Renew expired certificates
Rule 'Azure.APIM.CertificateExpiry' -Type 'Microsoft.ApiManagement/service' -Tag @{ release = 'GA' } {
    $configurations = @($TargetObject.Properties.hostnameConfigurations | Where-Object {
        $Null -ne $_.certificate
    })
    if ($configurations.Length -eq 0) {
        $True;
    }
    else {
        foreach ($configuration in $configurations) {
            $remaining = ($configuration.certificate.expiry - [DateTime]::Now).Days;
            $Assert.
                GreaterOrEqual($remaining, '.', $Configuration.Azure_MinimumCertificateLifetime).
                WithReason(($LocalizedData.APIMCertificateExpiry -f $configuration.hostName, $configuration.certificate.expiry.ToString('yyyy/MM/dd')), $True);
        }
    }
} -Configure @{ Azure_MinimumCertificateLifetime = 30 }
