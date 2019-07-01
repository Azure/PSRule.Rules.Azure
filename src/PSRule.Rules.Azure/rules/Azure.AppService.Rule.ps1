#
# Validation rules for Azure App Services
#

# Synopsis: Use an App Service Plan with at least two (2) instances
Rule 'Azure.AppService.PlanInstanceCount' -If { ResourceType 'Microsoft.Web/serverfarms' } -Tag @{ severity = 'Single point of failure'; category = 'Reliability' } {
    $TargetObject.Sku.capacity -ge 2
}

# Synopsis: Use at least a Standard App Service Plan
Rule 'Azure.AppService.MinPlan' -If { ResourceType 'Microsoft.Web/serverfarms' } -Tag @{ severity = 'Important'; category = 'Performance' } {
    Recommend 'Use a Standard or high plans for production services'

    ($TargetObject.Sku.tier -eq 'PremiumV2') -or
    ($TargetObject.Sku.tier -eq 'Premium') -or
    ($TargetObject.Sku.tier -eq 'Standard')
}

# Synopsis: Disable client affinity for stateless services
Rule 'Azure.AppService.ARRAffinity' -If { ResourceType 'Microsoft.Web/sites' } -Tag @{ severity = 'Awareness'; category = 'Performance' } {
    Recommend 'Disable ARR affinity when not required'

    $TargetObject.Properties.clientAffinityEnabled -eq $False
}

# Synopsis: Use HTTPS only
Rule 'Azure.AppService.UseHTTPS' -If { ResourceType 'Microsoft.Web/sites' } -Tag @{ severity = 'Important'; category = 'Security configuration' } {
    Recommend 'Disable HTTP when not required'

    $TargetObject.Properties.httpsOnly -eq $True
}
