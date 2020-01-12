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
            $Assert.StartsWith($backend, 'properties.url', 'https://')
        }
        $apis = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/apis')
        if ($apis.Length -eq 0) {
            $True;
        }
        foreach ($api in $apis) {
            $Assert.StartsWith($api, 'properties.serviceUrl', 'https://')
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service/apis') {
        $Assert.StartsWith($TargetObject, 'properties.serviceUrl', 'https://')
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service/backends') {
        $Assert.StartsWith($TargetObject, 'properties.url', 'https://')
    }
}

# Synopsis: Encrypt all named values
Rule 'Azure.APIM.EncryptValues' -Type 'Microsoft.ApiManagement/service', 'Microsoft.ApiManagement/service/properties' -Tag @{ release = 'GA' } {
    if ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service') {
        $properties = @(GetSubResources -ResourceType 'Microsoft.ApiManagement/service/properties')
        if ($properties.Length -eq 0) {
            $True;
        }
        foreach ($prop in $properties) {
            $Assert.HasFieldValue($prop, 'properties.secret', $True)
        }
    }
    elseif ($PSRule.TargetType -eq 'Microsoft.ApiManagement/service/properties') {
        $Assert.HasFieldValue($TargetObject, 'properties.secret', $True)
    }
}
