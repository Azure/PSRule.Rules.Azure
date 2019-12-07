#
# Validation rules for Azure Redis Cache
#

# Synopsis: Redis Cache should only accept secure connections
Rule 'Azure.Redis.NonSslPort' -Type 'Microsoft.Cache/Redis' -Tag @{ release = 'GA'; severity = 'Critical'; category = 'Security configuration' } {
    $TargetObject.properties.enableNonSslPort -eq $False
}

# Synopsis: Redis Cache should reject TLS versions older then 1.2
Rule 'Azure.Redis.MinTLS' -Type 'Microsoft.Cache/Redis' -Tag @{ release = 'GA'; severity = 'Critical'; category = 'Security configuration' } {
    $TargetObject.properties.minimumTlsVersion -eq '1.2'
}
