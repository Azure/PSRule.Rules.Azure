#
# Validation rules for Azure Data Factory
#

# Synopsis: Consider migrating to DataFactory v2
Rule 'Azure.DataFactory.Version' -Type 'Microsoft.DataFactory/datafactories', 'Microsoft.DataFactory/factories' -Tag @{ release = 'GA' } {
    $TargetObject.ResourceType -eq 'Microsoft.DataFactory/factories'
}
