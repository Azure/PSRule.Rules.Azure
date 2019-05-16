#
# Validation rules for Azure Data Factory
#

# Description: Consider migrating to DataFactory v2
Rule 'Azure.DataFactory.Version' -If { (ResourceType 'Microsoft.DataFactory/datafactories') -or (ResourceType 'Microsoft.DataFactory/factories') } -Tag @{ severity = 'Awareness'; category = 'Operations management' } {
    $TargetObject.ResourceType -eq 'Microsoft.DataFactory/factories'
}
