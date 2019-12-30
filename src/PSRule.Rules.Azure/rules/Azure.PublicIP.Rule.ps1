#
# Validation rules for public IP addresses
#

# Synopsis: Public IP addresses should be attached or cleaned up if not in use
Rule 'Azure.PublicIP.IsAttached' -Type 'Microsoft.Network/publicIPAddresses' -Tag @{ release = 'GA' } {
    $Assert.HasFieldValue($TargetObject, 'Properties.ipConfiguration.id')
}
