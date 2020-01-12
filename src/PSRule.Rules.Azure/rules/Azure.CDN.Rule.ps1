#
# Validation rules for Azure CDN
#

# Synopsis: Only use secure transport
Rule 'Azure.CDN.HTTP' -Type 'Microsoft.Cdn/profiles/endpoints' -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'properties.isHttpAllowed', $False)
}
