#
# Validation rules for Azure Database for MySQL
#

# Description: Use encrypted MySQL connections
Rule 'Azure.MySQL.UseSSL' -If { ResourceType 'Microsoft.DBforMySQL/servers' } -Tag @{ severity = 'Critical'; category = 'Security configuration' } {
    Within 'Properties.sslEnforcement' 'Enabled'
}
