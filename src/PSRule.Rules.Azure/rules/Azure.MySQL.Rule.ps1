#
# Validation rules for Azure Database for MySQL
#

# Synopsis: Use encrypted MySQL connections
Rule 'Azure.MySQL.UseSSL' -If { ResourceType 'Microsoft.DBforMySQL/servers' } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    Within 'Properties.sslEnforcement' 'Enabled'
}
