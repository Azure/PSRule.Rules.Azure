#
# Validation rules for public IP addresses
#

# Description: Public IP addresses should be attached or cleaned up if not in use
Rule 'Azure.PublicIP.IsAttached' -If { ResourceType 'Microsoft.Network/publicIPAddresses' } -Tag @{ severity = 'Awareness'; category = 'Operations management' } {
    Hint 'Public IP address should be attached'

    ($Null -ne $TargetObject.Properties.ipConfiguration) -and
    (![String]::IsNullOrEmpty($TargetObject.Properties.ipConfiguration.id))
}
