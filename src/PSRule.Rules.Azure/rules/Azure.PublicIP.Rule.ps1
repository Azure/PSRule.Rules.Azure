#
# Validation rules for public IP addresses
#

# Synopsis: Public IP addresses should be attached or cleaned up if not in use
Rule 'Azure.PublicIP.IsAttached' -Type 'Microsoft.Network/publicIPAddresses' -Tag @{ severity = 'Awareness'; category = 'Operations management' } {
    Recommend 'Public IP address should be attached'

    ($Null -ne $TargetObject.Properties.ipConfiguration) -and
    (![String]::IsNullOrEmpty($TargetObject.Properties.ipConfiguration.id))
}
