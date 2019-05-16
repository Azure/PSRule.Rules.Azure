#
# Validation rules for Azure Redis Cache
#

# Description: Redis Cache should only accept secure connections
Rule 'Azure.Redis.NonSslPort' -If { ResourceType 'Microsoft.Cache/Redis' } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    $TargetObject.properties.enableNonSslPort -eq $False
}

# Description: Redis Cache should reject TLS versions older then 1.2
Rule 'Azure.Redis.MinTLS' -If { ResourceType 'Microsoft.Cache/Redis' } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    $TargetObject.properties.minimumTlsVersion -eq '1.2'
}
